//
//  BART_WIDGET.swift
//  BART WIDGET
//
//  Created by Fairwin Li on 12/18/25.
//

import WidgetKit
import SwiftUI
import CoreLocation

// MARK: - Widget Entry
struct BARTDepartureEntry: TimelineEntry {
    let date: Date
    let station: Station?
    let error: String?
    let isLocationAuthorized: Bool
}

// MARK: - Widget Provider
struct BARTDepartureProvider: TimelineProvider {
    typealias Entry = BARTDepartureEntry
    
    private let bartAPI = BARTAPIService.shared
    
    private var locationManager: CLLocationManager {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }
    
    func placeholder(in context: Context) -> BARTDepartureEntry {
        BARTDepartureEntry(
            date: Date(),
            station: createPlaceholderStation(),
            error: nil,
            isLocationAuthorized: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BARTDepartureEntry) -> Void) {
        let entry = BARTDepartureEntry(
            date: Date(),
            station: createPlaceholderStation(),
            error: nil,
            isLocationAuthorized: CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BARTDepartureEntry>) -> Void) {
        let currentDate = Date()
        
        // Check location authorization
        let authStatus = CLLocationManager.authorizationStatus()
        let isAuthorized = authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways
        
        if !isAuthorized {
            // Location not authorized
            let entry = BARTDepartureEntry(
                date: currentDate,
                station: nil,
                error: "Location access required. Please enable location in Settings.",
                isLocationAuthorized: false
            )
            let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(300)))
            completion(timeline)
            return
        }
        
        // Widgets cannot directly access location services
        // Read location from shared App Group (set by main app)
        let location: CLLocation
        if let sharedLocation = SharedLocationManager.getLocation() {
            location = sharedLocation
        } else {
            // Fallback to default location if shared location is not available
            location = CLLocation(latitude: 37.7849, longitude: -122.4074) // Powell St station
        }
        
        // Find nearest station and fetch data
        Task {
            do {
                let nearestStation = try await findNearestStationAndFetchData(location: location)
                
                let entry = BARTDepartureEntry(
                    date: currentDate,
                    station: nearestStation,
                    error: nil,
                    isLocationAuthorized: true
                )
                
                // Refresh every 2 minutes
                let nextUpdate = currentDate.addingTimeInterval(120)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                let entry = BARTDepartureEntry(
                    date: currentDate,
                    station: nil,
                    error: "Error loading data: \(error.localizedDescription)",
                    isLocationAuthorized: true
                )
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(60)))
                completion(timeline)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func findNearestStationAndFetchData(location: CLLocation) async throws -> Station {
        // Get all BART stations with their locations
        let allStations = try await bartAPI.fetchAllStations()
        
        // Find nearest station
        var nearestStation: (info: BARTAPIService.BARTStationInfo, distance: Double)?
        var minDistance = Double.infinity
        
        for stationInfo in allStations {
            guard let lat = Double(stationInfo.gtfs_latitude),
                  let lon = Double(stationInfo.gtfs_longitude) else {
                continue
            }
            
            let stationLocation = CLLocation(latitude: lat, longitude: lon)
            let distance = location.distance(from: stationLocation) / 1609.34 // Convert to miles
            
            if distance < minDistance {
                minDistance = distance
                nearestStation = (stationInfo, distance)
            }
        }
        
        guard let nearest = nearestStation else {
            throw NSError(domain: "BARTWidget", code: 1, userInfo: [NSLocalizedDescriptionKey: "No stations found"])
        }
        
        // Fetch departures for nearest station
        let etds = try await bartAPI.fetchDepartures(for: nearest.info.abbr)
        
        // Convert to Station model
        let stationLocation = CLLocationCoordinate2D(
            latitude: Double(nearest.info.gtfs_latitude) ?? 0,
            longitude: Double(nearest.info.gtfs_longitude) ?? 0
        )
        
        let platforms = convertETDsToPlatforms(etds: etds)
        let warning = checkForWarnings(etds: etds)
        
        return Station(
            name: nearest.info.name,
            system: "BART",
            distance: nearest.distance,
            lastUpdated: Date(),
            warning: warning,
            platforms: platforms,
            location: stationLocation
        )
    }
    
    private func convertETDsToPlatforms(etds: [BARTAPIService.BARTETD]) -> [Platform] {
        var platformMap: [String: [Train]] = [:]
        var directionMap: [String: String] = [:]
        
        for etd in etds {
            for estimate in etd.estimate {
                let platformKey = estimate.platform.isEmpty ? "Unknown" : "Platform \(estimate.platform)"
                let direction = estimate.direction
                
                if directionMap[platformKey] == nil {
                    directionMap[platformKey] = direction
                }
                
                let minutes = Int(estimate.minutes) ?? 0
                let calendar = Calendar.current
                let arrivalTime = calendar.date(byAdding: .minute, value: minutes, to: Date()) ?? Date()
                
                let status: Train.TrainStatus = {
                    if let delay = estimate.delay, delay != "0" {
                        return .delayed
                    } else if minutes < 0 {
                        return .cancelled
                    } else {
                        return .onTime
                    }
                }()
                
                let lineColor = estimate.effectiveColor
                let lineName = estimate.color.isEmpty ? "BART" : estimate.color
                
                let train = Train(
                    line: lineName,
                    destination: etd.destination,
                    minutes: minutes,
                    time: arrivalTime,
                    status: status,
                    color: lineColor
                )
                
                if platformMap[platformKey] == nil {
                    platformMap[platformKey] = []
                }
                platformMap[platformKey]?.append(train)
            }
        }
        
        var platforms: [Platform] = []
        for (platformName, trains) in platformMap {
            let sortedTrains = trains.sorted { $0.minutes < $1.minutes }
            let direction = directionMap[platformName] ?? "Unknown"
            
            platforms.append(Platform(
                name: platformName,
                direction: direction,
                trains: sortedTrains
            ))
        }
        
        return platforms.sorted { $0.name < $1.name }
    }
    
    private func checkForWarnings(etds: [BARTAPIService.BARTETD]) -> Warning? {
        var hasDelays = false
        var delayMessages: [String] = []
        
        for etd in etds {
            for estimate in etd.estimate {
                if let delay = estimate.delay, delay != "0", let delayInt = Int(delay), delayInt > 0 {
                    // Cap unrealistic delays at 60 minutes for display
                    let displayDelay = min(delayInt, 60)
                    hasDelays = true
                    let message = "\(etd.destination): \(displayDelay) min delay"
                    if !delayMessages.contains(message) {
                        delayMessages.append(message)
                    }
                }
            }
        }
        
        if hasDelays {
            let description = delayMessages.prefix(3).joined(separator: ". ")
            return Warning(
                hasWarning: true,
                title: "Service Delays",
                description: description
            )
        }
        
        return nil
    }
    
    private func createPlaceholderStation() -> Station {
        let now = Date()
        let calendar = Calendar.current
        
        let train1 = Train(
            line: "Blue",
            destination: "Dublin/Pleasanton",
            minutes: 3,
            time: calendar.date(byAdding: .minute, value: 3, to: now) ?? now,
            status: .onTime,
            color: "#0099CC"
        )
        
        let train2 = Train(
            line: "Orange",
            destination: "Richmond",
            minutes: 8,
            time: calendar.date(byAdding: .minute, value: 8, to: now) ?? now,
            status: .onTime,
            color: "#FF9933"
        )
        
        let platform = Platform(
            name: "Platform 1",
            direction: "Northbound",
            trains: [train1, train2]
        )
        
        return Station(
            name: "San Leandro Station",
            system: "BART",
            distance: 0.4,
            lastUpdated: now,
            warning: nil,
            platforms: [platform],
            location: CLLocationCoordinate2D(latitude: 37.7219, longitude: -122.1608)
        )
    }
}

// MARK: - Widget View
struct BART_WIDGETEntryView: View {
    var entry: BARTDepartureProvider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if let error = entry.error {
            errorView(error: error, needsLocation: !entry.isLocationAuthorized)
        } else if let station = entry.station {
            switch family {
            case .systemMedium:
                MediumWidget(station: station, isDark: colorScheme == .dark)
            case .systemLarge:
                LargeWidget(station: station, isDark: colorScheme == .dark)
            default:
                LargeWidget(station: station, isDark: colorScheme == .dark)
            }
        } else {
            loadingView
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: String, needsLocation: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: needsLocation ? "location.slash" : "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(needsLocation ? "Location Required" : "Error")
                .font(.headline)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Widget Configuration
struct BART_WIDGET: Widget {
    let kind: String = "BART_WIDGET"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BARTDepartureProvider()) { entry in
            BART_WIDGETEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("BART Departures")
        .description("Shows real-time train departures from your nearest BART station.")
        .supportedFamilies([.systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

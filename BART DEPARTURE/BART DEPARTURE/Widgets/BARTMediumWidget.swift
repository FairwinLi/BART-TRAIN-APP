import WidgetKit
import SwiftUI
import CoreLocation

// MARK: - Medium Widget Entry
struct BARTMediumWidgetEntry: TimelineEntry {
    let date: Date
    let station: Station?
    let closestTrains: [Train] // Top 3 closest trains across all platforms
    let error: String?
    let isLocationAuthorized: Bool
}

// MARK: - Medium Widget Provider
struct BARTMediumWidgetProvider: TimelineProvider {
    typealias Entry = BARTMediumWidgetEntry
    
    private let bartAPI = BARTAPIService.shared
    
    private var locationManager: CLLocationManager {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }
    
    func placeholder(in context: Context) -> BARTMediumWidgetEntry {
        let placeholderStation = createPlaceholderStation()
        let closestTrains = getClosestTrains(from: placeholderStation, count: 3)
        return BARTMediumWidgetEntry(
            date: Date(),
            station: placeholderStation,
            closestTrains: closestTrains,
            error: nil,
            isLocationAuthorized: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BARTMediumWidgetEntry) -> Void) {
        let placeholderStation = createPlaceholderStation()
        let closestTrains = getClosestTrains(from: placeholderStation, count: 3)
        let entry = BARTMediumWidgetEntry(
            date: Date(),
            station: placeholderStation,
            closestTrains: closestTrains,
            error: nil,
            isLocationAuthorized: CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BARTMediumWidgetEntry>) -> Void) {
        let currentDate = Date()
        
        // Check location authorization
        let authStatus = CLLocationManager.authorizationStatus()
        let isAuthorized = authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways
        
        if !isAuthorized {
            let entry = BARTMediumWidgetEntry(
                date: currentDate,
                station: nil,
                closestTrains: [],
                error: "Location access required",
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
                let closestTrains = getClosestTrains(from: nearestStation, count: 3)
                
                let entry = BARTMediumWidgetEntry(
                    date: currentDate,
                    station: nearestStation,
                    closestTrains: closestTrains,
                    error: nil,
                    isLocationAuthorized: true
                )
                
                // Refresh every 2 minutes
                let nextUpdate = currentDate.addingTimeInterval(120)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                let entry = BARTMediumWidgetEntry(
                    date: currentDate,
                    station: nil,
                    closestTrains: [],
                    error: "Error: \(error.localizedDescription)",
                    isLocationAuthorized: true
                )
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(60)))
                completion(timeline)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getClosestTrains(from station: Station, count: Int) -> [Train] {
        // Combine all trains from all platforms
        var allTrains: [Train] = []
        for platform in station.platforms {
            allTrains.append(contentsOf: platform.trains)
        }
        
        // Sort by minutes (closest first) and take top N
        return allTrains.sorted { $0.minutes < $1.minutes }.prefix(count).map { $0 }
    }
    
    private func findNearestStationAndFetchData(location: CLLocation) async throws -> Station {
        // Get all BART stations to find the nearest one
        let allStations = try await bartAPI.fetchAllStations()
        
        // Find nearest station
        var nearestStationInfo: BARTAPIService.BARTStationInfo?
        var minDistance: Double = Double.infinity
        
        for stationInfo in allStations {
            guard let lat = Double(stationInfo.gtfs_latitude),
                  let lon = Double(stationInfo.gtfs_longitude) else {
                continue
            }
            
            let stationLocation = CLLocation(latitude: lat, longitude: lon)
            let distance = location.distance(from: stationLocation) / 1609.34 // Convert to miles
            
            if distance < minDistance {
                minDistance = distance
                nearestStationInfo = stationInfo
            }
        }
        
        guard let nearest = nearestStationInfo else {
            throw NSError(domain: "BARTWidget", code: 1, userInfo: [NSLocalizedDescriptionKey: "No stations found"])
        }
        
        // Fetch departures for nearest station
        let etds = try await bartAPI.fetchDepartures(for: nearest.abbr)
        
        // Convert to Station model
        let stationLocation = CLLocationCoordinate2D(
            latitude: Double(nearest.gtfs_latitude) ?? 0,
            longitude: Double(nearest.gtfs_longitude) ?? 0
        )
        
        let platforms = convertETDsToPlatforms(etds: etds)
        let warning = checkForWarnings(etds: etds)
        
        return Station(
            name: nearest.name,
            system: "BART",
            distance: minDistance,
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
                
                // Cap unrealistic delays at 60 minutes (values > 60 are likely API errors)
                let delayMinutes: Int? = {
                    if let delayString = estimate.delay, delayString != "0", let delay = Int(delayString), delay > 0 {
                        return min(delay, 60)
                    }
                    return nil
                }()
                
                let status: Train.TrainStatus = {
                    if delayMinutes != nil {
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
                    color: lineColor,
                    delayMinutes: delayMinutes
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
        
        let train3 = Train(
            line: "Red",
            destination: "Millbrae",
            minutes: 12,
            time: calendar.date(byAdding: .minute, value: 12, to: now) ?? now,
            status: .onTime,
            color: "#FF0000"
        )
        
        let platform = Platform(
            name: "Platform 1",
            direction: "Northbound",
            trains: [train1, train2, train3]
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

// MARK: - Medium Widget View
struct BARTMediumWidgetView: View {
    var entry: BARTMediumWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    private var isDark: Bool {
        colorScheme == .dark
    }
    
    var body: some View {
        if let error = entry.error {
            errorView(error: error, needsLocation: !entry.isLocationAuthorized)
        } else if let station = entry.station, !entry.closestTrains.isEmpty {
            MediumWidgetContent(
                station: station,
                closestTrains: entry.closestTrains,
                isDark: isDark
            )
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

// MARK: - Medium Widget Content
struct MediumWidgetContent: View {
    let station: Station
    let closestTrains: [Train]
    let isDark: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isDark ? .white : .black)
                        .lineLimit(1)
                    
                    Text("Nearest station • \(station.system)")
                        .font(.system(size: 9))
                        .foregroundColor(isDark ? .gray : .gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                        .foregroundColor(isDark ? .gray : .gray)
                    
                    Text(Date(), style: .time)
                        .font(.system(size: 9))
                        .foregroundColor(isDark ? .gray : .gray)
                }
            }
            
            // Top 3 Closest Trains (across all platforms)
            VStack(alignment: .leading, spacing: 6) {
                Text("Next 3 Departures")
                    .font(.system(size: 9))
                    .foregroundColor(isDark ? Color.gray.opacity(0.8) : Color.gray.opacity(0.6))
                    .padding(.bottom, 2)
                
                ForEach(closestTrains.prefix(3)) { train in
                    HStack(spacing: 8) {
                        // Line Badge
                        Text(train.line)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(train.color))
                            .cornerRadius(4)
                        
                        // Destination
                        VStack(alignment: .leading, spacing: 1) {
                            Text(train.destination)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(isDark ? .white : .black)
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                Text(train.time, style: .time)
                                    .font(.system(size: 9))
                                    .foregroundColor(isDark ? .gray : .gray)
                                
                                if train.status != .onTime {
                                    Text("•")
                                        .foregroundColor(isDark ? .gray : .gray)
                                    
                                    if let delay = train.delayMinutes {
                                        Text("\(delay) min delay")
                                            .font(.system(size: 9))
                                            .foregroundColor(isDark ? .orange : .orange)
                                    } else {
                                        Text("Delayed")
                                            .font(.system(size: 9))
                                            .foregroundColor(isDark ? .orange : .orange)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Minutes
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("\(train.minutes)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(isDark ? .white : .black)
                            
                            Text("min")
                                .font(.system(size: 9))
                                .foregroundColor(isDark ? .gray : .gray)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(isDark ? Color(white: 0.2) : Color(white: 0.95))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Warning/Status Bar
            HStack(spacing: 6) {
                Text(station.warning?.hasWarning == true ? "⚠️" : "✓")
                    .font(.system(size: 10))
                
                Text(station.warning?.hasWarning == true
                     ? (station.warning?.title ?? "All lines running normally")
                     : "All lines running normally")
                    .font(.system(size: 9))
                    .foregroundColor(
                        station.warning?.hasWarning == true
                        ? (isDark ? Color.orange.opacity(0.8) : Color.orange.opacity(0.8))
                        : (isDark ? Color.green.opacity(0.8) : Color.green.opacity(0.8))
                    )
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                station.warning?.hasWarning == true
                ? (isDark ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                : (isDark ? Color.green.opacity(0.2) : Color.green.opacity(0.1))
            )
            .cornerRadius(6)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isDark ? Color(white: 0.15) : .white)
    }
}

// MARK: - Medium Widget Configuration
struct BARTMediumWidget: Widget {
    let kind: String = "BARTMediumWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BARTMediumWidgetProvider()) { entry in
            BARTMediumWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("BART Next Departures")
        .description("Shows the 3 closest train departures from your nearest BART station.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}


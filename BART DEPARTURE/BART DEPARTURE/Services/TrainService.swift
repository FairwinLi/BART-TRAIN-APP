import Foundation
import CoreLocation

@MainActor
class TrainService: ObservableObject {
    @Published var stations: [Station] = []
    @Published var nearestStation: Station?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let locationService: LocationService
    private let bartAPI = BARTAPIService.shared
    
    // Common BART stations to fetch (you can modify this list)
    // Station abbreviations: https://api.bart.gov/docs/overview/abbrev.aspx
    private var stationAbbreviations = ["SANL", "BAYF", "HAYW", "EMBR", "MONT", "POWL", "CIVC", "16TH", "24TH"]
    
    // Option to fetch all stations (slower but comprehensive)
    var fetchAllStations = false
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func fetchStations() async {
        isLoading = true
        error = nil
        
        // First, we need location to find nearest station
        guard let currentLocation = locationService.currentLocation else {
            self.error = NSError(
                domain: "TrainService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Location unavailable. Please enable location services to find the nearest station."]
            )
            isLoading = false
            return
        }
        
        // Debug: Log the location being used
        print("📍 Using location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        print("📍 Location accuracy: \(currentLocation.horizontalAccuracy) meters")
        
        do {
            // Get all BART stations to find the nearest one
            let allStations = try await bartAPI.fetchAllStations()
            
            // Find nearest station based on location
            var nearestStationInfo: BARTAPIService.BARTStationInfo?
            var minDistance: Double = Double.infinity
            var allDistances: [(name: String, distance: Double)] = []
            
            for stationInfo in allStations {
                guard let lat = Double(stationInfo.gtfs_latitude),
                      let lon = Double(stationInfo.gtfs_longitude) else {
                    continue
                }
                
                let stationLocation = CLLocation(latitude: lat, longitude: lon)
                let distance = currentLocation.distance(from: stationLocation) / 1609.34 // Convert to miles
                
                allDistances.append((name: stationInfo.name, distance: distance))
                
                if distance < minDistance {
                    minDistance = distance
                    nearestStationInfo = stationInfo
                }
            }
            
            // Debug: Log the top 5 closest stations
            let sortedDistances = allDistances.sorted { $0.distance < $1.distance }
            print("📍 Top 5 closest stations:")
            for (index, station) in sortedDistances.prefix(5).enumerated() {
                print("  \(index + 1). \(station.name): \(String(format: "%.2f", station.distance)) miles")
            }
            
            if let nearest = nearestStationInfo {
                print("📍 Selected nearest station: \(nearest.name) (\(String(format: "%.2f", minDistance)) miles away)")
            }
            
            guard let nearest = nearestStationInfo else {
                throw NSError(
                    domain: "TrainService",
                    code: 3,
                    userInfo: [NSLocalizedDescriptionKey: "No BART stations found. Please try again."]
                )
            }
            
            // Fetch data only for the nearest station
            let station = try await withTimeout(seconds: 10) {
                try await self.fetchStationData(abbreviation: nearest.abbr)
            }
            
            // Create station with distance
            let updatedStation = Station(
                id: station.id,
                name: station.name,
                system: station.system,
                distance: minDistance,
                lastUpdated: station.lastUpdated,
                warning: station.warning,
                platforms: station.platforms,
                location: station.location
            )
            
            // Set as nearest station
            nearestStation = updatedStation
            stations = [updatedStation] // Keep for compatibility, but only one station
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            print("Failed to load nearest station: \(error.localizedDescription)")
        }
    }
    
    // Helper function for timeout
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "Timeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    func refreshData() async {
        await fetchStations()
    }
    
    func updateNearestStation(with location: CLLocation) {
        // This is now handled in fetchStations, but keeping for compatibility
        // If we already have a station, just update its distance
        if var station = nearestStation, let stationLocation = station.location {
            let distance = locationService.calculateDistance(from: location, to: stationLocation)
            station.distance = distance
            nearestStation = station
        } else {
            // If no station yet, fetch it
            Task {
                await fetchStations()
            }
        }
    }
    
    // MARK: - BART API Integration
    
    private func fetchStationData(abbreviation: String) async throws -> Station {
        // Fetch departures from BART API
        let etds = try await bartAPI.fetchDepartures(for: abbreviation)
        
        // Get station info from API response or fallback
        let stationName = bartAPI.getStationName(abbr: abbreviation) ?? abbreviation
        let stationLocation = bartAPI.getStationLocation(abbr: abbreviation)
        
        // Convert BART ETD data to our Platform/Train models
        let platforms = convertETDsToPlatforms(etds: etds)
        
        // Check for delays/warnings
        let warning = checkForWarnings(etds: etds)
        
        return Station(
            name: stationName,
            system: "BART",
            distance: nil, // Will be set by caller
            lastUpdated: Date(),
            warning: warning,
            platforms: platforms,
            location: stationLocation
        )
    }
    
    private func convertETDsToPlatforms(etds: [BARTAPIService.BARTETD]) -> [Platform] {
        // Group trains by platform and direction
        var platformMap: [String: [Train]] = [:]
        var directionMap: [String: String] = [:]
        
        for etd in etds {
            for estimate in etd.estimate {
                let platformKey = estimate.platform.isEmpty ? "Unknown" : "Platform \(estimate.platform)"
                let direction = estimate.direction
                
                // Store direction for this platform
                if directionMap[platformKey] == nil {
                    directionMap[platformKey] = direction
                }
                
                // Convert minutes string to Int
                let minutes = Int(estimate.minutes) ?? 0
                
                // Calculate arrival time
                let calendar = Calendar.current
                let arrivalTime = calendar.date(byAdding: .minute, value: minutes, to: Date()) ?? Date()
                
                // Parse delay from API (real-time delay data)
                // Note: BART API sometimes returns unrealistic delay values (> 100 min)
                // We cap delays at 60 minutes as a reasonable maximum
                let delayMinutes: Int? = {
                    if let delayString = estimate.delay, delayString != "0", let delay = Int(delayString), delay > 0 {
                        // Cap unrealistic delays at 60 minutes (values > 60 are likely API errors)
                        return min(delay, 60)
                    }
                    return nil
                }()
                
                // Determine status based on API delay data
                let status: Train.TrainStatus = {
                    if delayMinutes != nil {
                        return .delayed
                    } else if minutes < 0 {
                        return .cancelled
                    } else {
                        return .onTime
                    }
                }()
                
                // Debug: Log delays from API
                if let delay = delayMinutes {
                    print("🚨 Delay detected from API: \(etd.destination) - \(delay) minutes")
                }
                
                // Get line color (use effectiveColor from estimate)
                let lineColor = estimate.effectiveColor
                
                // Get line name (use color or destination abbreviation)
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
        
        // Convert to Platform array
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
        
        // Sort platforms by name
        return platforms.sorted { $0.name < $1.name }
    }
    
    private func checkForWarnings(etds: [BARTAPIService.BARTETD]) -> Warning? {
        // Check for delays
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
    
    // MARK: - Fetch Specific Station
    func fetchStation(abbreviation: String) async throws -> Station {
        return try await fetchStationData(abbreviation: abbreviation)
    }
    
    // MARK: - Update Station List
    func updateStationList(_ abbreviations: [String]) {
        // Update which stations to fetch
        // This could be used for user preferences or location-based filtering
    }
}

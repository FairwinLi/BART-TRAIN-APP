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
        
        do {
            var fetchedStations: [Station] = []
            
            // If fetchAllStations is true, get all station abbreviations first
            var stationsToFetch = stationAbbreviations
            if fetchAllStations {
                let allStations = try await bartAPI.fetchAllStations()
                stationsToFetch = allStations.map { $0.abbr }
            }
            
            // Fetch departures for each station (limit to prevent too many API calls)
            let stationsToProcess = Array(stationsToFetch.prefix(20)) // Limit to 20 stations
            
            // Fetch in parallel with concurrency limit
            await withTaskGroup(of: Station?.self) { group in
                for stationAbbr in stationsToProcess {
                    group.addTask {
                        do {
                            return try await self.fetchStationData(abbreviation: stationAbbr)
                        } catch {
                            print("Error fetching \(stationAbbr): \(error.localizedDescription)")
                            return nil
                        }
                    }
                }
                
                for await station in group {
                    if let station = station {
                        fetchedStations.append(station)
                    }
                }
            }
            
            stations = fetchedStations.sorted { $0.name < $1.name }
            
            // Update nearest station if we have location
            if let currentLocation = locationService.currentLocation {
                updateNearestStation(with: currentLocation)
            }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func refreshData() async {
        await fetchStations()
    }
    
    func updateNearestStation(with location: CLLocation) {
        var nearest: Station?
        var minDistance: Double = Double.infinity
        
        for var station in stations {
            if let stationLocation = station.location {
                let distance = locationService.calculateDistance(from: location, to: stationLocation)
                station.distance = distance
                
                if distance < minDistance {
                    minDistance = distance
                    nearest = station
                }
            }
        }
        
        nearestStation = nearest
    }
    
    // MARK: - BART API Integration
    
    private func fetchStationData(abbreviation: String) async throws -> Station {
        // Fetch departures from BART API
        let etds = try await bartAPI.fetchDepartures(for: abbreviation)
        
        // Get station info
        let stationName = bartAPI.getStationName(abbr: abbreviation) ?? abbreviation
        let stationLocation = bartAPI.getStationLocation(abbr: abbreviation)
        
        // Convert BART ETD data to our Platform/Train models
        let platforms = convertETDsToPlatforms(etds: etds)
        
        // Check for delays/warnings
        let warning = checkForWarnings(etds: etds)
        
        return Station(
            name: stationName,
            system: "BART",
            distance: nil,
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
                
                // Determine status
                let status: Train.TrainStatus = {
                    if let delay = estimate.delay, delay != "0" {
                        return .delayed
                    } else if minutes < 0 {
                        return .cancelled
                    } else {
                        return .onTime
                    }
                }()
                
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
                    color: lineColor
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
                    hasDelays = true
                    let message = "\(etd.destination): \(delay) min delay"
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

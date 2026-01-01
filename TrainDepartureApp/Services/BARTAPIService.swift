import Foundation
import CoreLocation

struct BARTAPIService {
    static let shared = BARTAPIService()
    private let apiKey = "MW9S-E7SL-26DU-VV8V" // Public BART API key
    private let baseURL = "https://api.bart.gov/api"
    
    private init() {}
    
    // MARK: - BART API Response Models
    struct BARTResponse: Codable {
        let root: BARTRoot
    }
    
    struct BARTRoot: Codable {
        let station: [BARTStation]?
        let stations: BARTStations?
        let message: BARTMessage?
        let uri: BARTURI?
    }
    
    struct BARTURI: Codable {
        let cdata: String?
    }
    
    struct BARTStations: Codable {
        let station: [BARTStationInfo]
    }
    
    struct BARTStationInfo: Codable {
        let name: String
        let abbr: String
        let gtfs_latitude: String
        let gtfs_longitude: String
    }
    
    struct BARTStation: Codable {
        let name: String
        let abbr: String
        let etd: [BARTETD]?
    }
    
    struct BARTETD: Codable {
        let destination: String
        let abbreviation: String?
        let estimate: [BARTEstimate]
    }
    
    struct BARTEstimate: Codable {
        let minutes: String
        let platform: String
        let direction: String
        let length: String
        let color: String
        let hexcolor: String?
        let bikeflag: String?
        let delay: String?
        
        // Use hexcolor if available, otherwise map color name to hex
        var effectiveColor: String {
            if let hex = hexcolor, !hex.isEmpty {
                return hex.hasPrefix("#") ? hex : "#\(hex)"
            }
            return BARTAPIService.lineColors[color.uppercased()] ?? "#0099CC"
        }
    }
    
    struct BARTMessage: Codable {
        let error: BARTError?
    }
    
    struct BARTError: Codable {
        let text: String
    }
    
    // MARK: - BART Station Abbreviations (common stations)
    static let stationAbbreviations: [String: (name: String, location: CLLocationCoordinate2D)] = [
        "SANL": ("San Leandro", CLLocationCoordinate2D(latitude: 37.7219, longitude: -122.1608)),
        "BAYF": ("Bay Fair", CLLocationCoordinate2D(latitude: 37.6974, longitude: -122.1261)),
        "HAYW": ("Hayward", CLLocationCoordinate2D(latitude: 37.6697, longitude: -122.0870)),
        "EMBR": ("Embarcadero", CLLocationCoordinate2D(latitude: 37.7930, longitude: -122.3965)),
        "MONT": ("Montgomery St", CLLocationCoordinate2D(latitude: 37.7894, longitude: -122.4013)),
        "POWL": ("Powell St", CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4074)),
        "CIVC": ("Civic Center", CLLocationCoordinate2D(latitude: 37.7795, longitude: -122.4138)),
        "16TH": ("16th St Mission", CLLocationCoordinate2D(latitude: 37.7650, longitude: -122.4194)),
        "24TH": ("24th St Mission", CLLocationCoordinate2D(latitude: 37.7524, longitude: -122.4181)),
        "GLEN": ("Glen Park", CLLocationCoordinate2D(latitude: 37.7331, longitude: -122.4338)),
        "BALB": ("Balboa Park", CLLocationCoordinate2D(latitude: 37.7216, longitude: -122.4475)),
        "DALY": ("Daly City", CLLocationCoordinate2D(latitude: 37.7061, longitude: -122.4691)),
        "DUBL": ("Dublin/Pleasanton", CLLocationCoordinate2D(latitude: 37.7017, longitude: -121.8992)),
        "FRMT": ("Fremont", CLLocationCoordinate2D(latitude: 37.5574, longitude: -121.9764)),
        "WARM": ("Warm Springs", CLLocationCoordinate2D(latitude: 37.5021, longitude: -121.9393)),
        "BERY": ("Berryessa", CLLocationCoordinate2D(latitude: 37.3686, longitude: -121.9000)),
        "RICH": ("Richmond", CLLocationCoordinate2D(latitude: 37.9369, longitude: -122.3531)),
        "PITT": ("Pittsburg/Bay Point", CLLocationCoordinate2D(latitude: 38.0189, longitude: -121.9450)),
        "ANTC": ("Antioch", CLLocationCoordinate2D(latitude: 37.9954, longitude: -121.7808)),
        "OAKL": ("Oakland Airport", CLLocationCoordinate2D(latitude: 37.7132, longitude: -122.2120)),
        "COLS": ("Coliseum", CLLocationCoordinate2D(latitude: 37.7537, longitude: -122.1969)),
        "LAKE": ("Lake Merritt", CLLocationCoordinate2D(latitude: 37.7974, longitude: -122.2651)),
        "12TH": ("12th St Oakland City Center", CLLocationCoordinate2D(latitude: 37.8037, longitude: -122.2715)),
        "19TH": ("19th St Oakland", CLLocationCoordinate2D(latitude: 37.8084, longitude: -122.2687)),
        "MCAR": ("MacArthur", CLLocationCoordinate2D(latitude: 37.8291, longitude: -122.2671)),
        "ROCK": ("Rockridge", CLLocationCoordinate2D(latitude: 37.8446, longitude: -122.2514)),
        "ORIN": ("Orinda", CLLocationCoordinate2D(latitude: 37.8784, longitude: -122.1838)),
        "LAFY": ("Lafayette", CLLocationCoordinate2D(latitude: 37.8931, longitude: -122.1247)),
        "WCRK": ("Walnut Creek", CLLocationCoordinate2D(latitude: 37.9055, longitude: -122.0675)),
        "PHIL": ("Pleasant Hill", CLLocationCoordinate2D(latitude: 37.9284, longitude: -122.0560)),
        "CONC": ("Concord", CLLocationCoordinate2D(latitude: 37.9737, longitude: -122.0290)),
        "NCON": ("North Concord", CLLocationCoordinate2D(latitude: 38.0032, longitude: -122.0246))
    ]
    
    // MARK: - Line Colors
    static let lineColors: [String: String] = [
        "RED": "#FF0000",
        "YELLOW": "#FFFF00",
        "BLUE": "#0099CC",
        "GREEN": "#00FF00",
        "ORANGE": "#FF9933",
        "WHITE": "#FFFFFF",
        "BLUE-ORANGE": "#0099CC",
        "YELLOW-RED": "#FF9933"
    ]
    
    // MARK: - Fetch Departures for a Station
    func fetchDepartures(for stationAbbr: String) async throws -> [BARTETD] {
        let urlString = "\(baseURL)/etd.aspx?cmd=etd&orig=\(stationAbbr)&key=\(apiKey)&json=y"
        guard let url = URL(string: urlString) else {
            throw BARTAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BARTAPIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let bartResponse = try decoder.decode(BARTResponse.self, from: data)
        
        if let error = bartResponse.root.message?.error {
            throw BARTAPIError.apiError(error.text)
        }
        
        guard let station = bartResponse.root.station?.first,
              let etds = station.etd else {
            throw BARTAPIError.noData
        }
        
        return etds
    }
    
    // MARK: - Fetch All Stations Info
    func fetchAllStations() async throws -> [BARTStationInfo] {
        let urlString = "\(baseURL)/stn.aspx?cmd=stns&key=\(apiKey)&json=y"
        guard let url = URL(string: urlString) else {
            throw BARTAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BARTAPIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let bartResponse = try decoder.decode(BARTResponse.self, from: data)
        
        guard let stations = bartResponse.root.stations?.station else {
            throw BARTAPIError.noData
        }
        
        return stations
    }
    
    // MARK: - Get Station Location
    func getStationLocation(abbr: String) -> CLLocationCoordinate2D? {
        return Self.stationAbbreviations[abbr]?.location
    }
    
    func getStationName(abbr: String) -> String? {
        return Self.stationAbbreviations[abbr]?.name
    }
}

// MARK: - BART API Errors
enum BARTAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from BART API"
        case .noData:
            return "No data available"
        case .apiError(let message):
            return "BART API Error: \(message)"
        }
    }
}


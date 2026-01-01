import Foundation
import CoreLocation

struct Station: Identifiable, Codable {
    let id: UUID
    let name: String
    let system: String
    var distance: Double? // in miles
    var lastUpdated: Date
    var warning: Warning?
    var platforms: [Platform]
    let location: CLLocationCoordinate2D?
    
    init(id: UUID = UUID(), name: String, system: String, distance: Double? = nil, lastUpdated: Date = Date(), warning: Warning? = nil, platforms: [Platform], location: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.name = name
        self.system = system
        self.distance = distance
        self.lastUpdated = lastUpdated
        self.warning = warning
        self.platforms = platforms
        self.location = location
    }
    
    var distanceString: String {
        guard let distance = distance else { return "Unknown distance" }
        return String(format: "%.1f miles away", distance)
    }
    
    var lastUpdatedString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}

struct Warning: Codable {
    let hasWarning: Bool
    let icon: String
    let title: String
    let description: String
    
    init(hasWarning: Bool, icon: String = "⚠️", title: String, description: String) {
        self.hasWarning = hasWarning
        self.icon = icon
        self.title = title
        self.description = description
    }
}

// MARK: - Codable support for CLLocationCoordinate2D
extension Station {
    enum CodingKeys: String, CodingKey {
        case id, name, system, distance, lastUpdated, warning, platforms, latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        system = try container.decode(String.self, forKey: .system)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        warning = try container.decodeIfPresent(Warning.self, forKey: .warning)
        platforms = try container.decode([Platform].self, forKey: .platforms)
        
        if let lat = try? container.decode(Double.self, forKey: .latitude),
           let lon = try? container.decode(Double.self, forKey: .longitude) {
            location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            location = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(system, forKey: .system)
        try container.encodeIfPresent(distance, forKey: .distance)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encodeIfPresent(warning, forKey: .warning)
        try container.encode(platforms, forKey: .platforms)
        if let location = location {
            try container.encode(location.latitude, forKey: .latitude)
            try container.encode(location.longitude, forKey: .longitude)
        }
    }
}


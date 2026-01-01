import Foundation
import CoreLocation

/// Manages sharing location data between the main app and widget extension via App Groups
class SharedLocationManager {
    // IMPORTANT: Replace with your actual App Group identifier
    // Get this from: Xcode → Target → Signing & Capabilities → App Groups
    // Format: group.com.yourname.BARTDeparture
    static let appGroupIdentifier = "group.com.FairwinLi.BARTDeparture"
    
    private static let locationKey = "sharedLocation"
    private static let locationTimestampKey = "locationTimestamp"
    
    // Maximum age of location data (in seconds) before it's considered stale
    private static let maxLocationAge: TimeInterval = 300 // 5 minutes
    
    /// Save location to shared UserDefaults
    static func saveLocation(_ location: CLLocation) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("⚠️ Failed to access App Group: \(appGroupIdentifier)")
            print("⚠️ Make sure App Groups capability is enabled for both targets")
            return
        }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "altitude": location.altitude,
            "horizontalAccuracy": location.horizontalAccuracy,
            "verticalAccuracy": location.verticalAccuracy,
            "timestamp": location.timestamp.timeIntervalSince1970
        ]
        
        sharedDefaults.set(locationData, forKey: locationKey)
        sharedDefaults.set(Date().timeIntervalSince1970, forKey: locationTimestampKey)
        sharedDefaults.synchronize()
        
        print("✅ Saved location to App Group: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    /// Read location from shared UserDefaults
    static func getLocation() -> CLLocation? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("⚠️ Failed to access App Group: \(appGroupIdentifier)")
            return nil
        }
        
        guard let locationData = sharedDefaults.dictionary(forKey: locationKey) else {
            print("ℹ️ No shared location data found")
            return nil
        }
        
        // Check if location data is too old
        if let timestamp = sharedDefaults.double(forKey: locationTimestampKey) as TimeInterval? {
            let age = Date().timeIntervalSince1970 - timestamp
            if age > maxLocationAge {
                print("⚠️ Shared location data is too old (\(Int(age)) seconds)")
                return nil
            }
        }
        
        guard let latitude = locationData["latitude"] as? Double,
              let longitude = locationData["longitude"] as? Double,
              let timestamp = locationData["timestamp"] as? TimeInterval else {
            print("⚠️ Invalid location data format")
            return nil
        }
        
        let altitude = locationData["altitude"] as? Double ?? 0
        let horizontalAccuracy = locationData["horizontalAccuracy"] as? Double ?? -1
        let verticalAccuracy = locationData["verticalAccuracy"] as? Double ?? -1
        
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            timestamp: Date(timeIntervalSince1970: timestamp)
        )
        
        print("✅ Retrieved location from App Group: \(latitude), \(longitude)")
        return location
    }
    
    /// Clear saved location data
    static func clearLocation() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return
        }
        
        sharedDefaults.removeObject(forKey: locationKey)
        sharedDefaults.removeObject(forKey: locationTimestampKey)
        sharedDefaults.synchronize()
    }
}


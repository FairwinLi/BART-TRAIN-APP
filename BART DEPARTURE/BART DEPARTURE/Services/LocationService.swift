import Foundation
import CoreLocation

@MainActor
class LocationService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var locationError: Error?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestAuthorization() {
        print("📍 Requesting location authorization...")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        // Check current authorization status
        let currentStatus = locationManager.authorizationStatus
        authorizationStatus = currentStatus
        
        print("📍 Location authorization status: \(currentStatus.rawValue)")
        
        guard currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways else {
            print("📍 Location not authorized, requesting permission...")
            requestAuthorization()
            return
        }
        
        print("📍 Starting location updates...")
        // Request location immediately (one-time)
        locationManager.requestLocation()
        // Also start continuous updates
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func calculateDistance(from location: CLLocation, to stationLocation: CLLocationCoordinate2D) -> Double {
        let stationLocationObj = CLLocation(latitude: stationLocation.latitude, longitude: stationLocation.longitude)
        return location.distance(from: stationLocationObj) / 1609.34 // Convert meters to miles
    }
    
    func refreshLocation() {
        print("📍 Manually refreshing location...")
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            requestAuthorization()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            if let location = locations.last {
                self.currentLocation = location
                print("📍 Location received: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                print("📍 Accuracy: \(location.horizontalAccuracy) meters")
                
                // Save location to shared UserDefaults for widget access
                SharedLocationManager.saveLocation(location)
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error
            print("❌ Location error: \(error.localizedDescription)")
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let newStatus = manager.authorizationStatus
            self.authorizationStatus = newStatus
            print("📍 Authorization changed to: \(newStatus.rawValue)")
            
            if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                print("📍 Starting location updates after authorization...")
                manager.requestLocation()
                manager.startUpdatingLocation()
            } else if newStatus == .denied || newStatus == .restricted {
                print("⚠️ Location access denied or restricted")
            }
        }
    }
}

// Helper extension for authorization status description
extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}

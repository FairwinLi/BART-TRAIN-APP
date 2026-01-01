import SwiftUI

struct ContentView: View {
    @StateObject private var trainService: TrainService
    @StateObject private var locationService: LocationService
    @State private var isDark = false
    @State private var isRefreshing = false
    
    init() {
        let locationService = LocationService()
        let trainService = TrainService(locationService: locationService)
        _locationService = StateObject(wrappedValue: locationService)
        _trainService = StateObject(wrappedValue: trainService)
    }
    
    var body: some View {
        ZStack {
            // Background
            (isDark ? Color.black : Color(white: 0.95))
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Status Bar (simulated)
                    if isDark {
                        Color.black.frame(height: 44)
                    } else {
                        Color.white.frame(height: 44)
                    }
                    
                    // App Content
                    VStack(alignment: .leading, spacing: 0) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(displayStation?.name ?? "Loading...")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(isDark ? .white : .black)
                                
                                Spacer()
                                
                                Button(action: {
                                    Task {
                                        isRefreshing = true
                                        await trainService.refreshData()
                                        isRefreshing = false
                                    }
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 20))
                                        .foregroundColor(isDark ? .white : .black)
                                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                        .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(8)
                                .background(isDark ? Color(white: 0.2) : .white)
                                .cornerRadius(20)
                            }
                            
                            if let station = displayStation {
                                Text(station.distanceString)
                                    .font(.system(size: 16))
                                    .foregroundColor(isDark ? .gray : .gray)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(isDark ? .blue : .blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Using current location")
                                            .font(.system(size: 14))
                                            .foregroundColor(isDark ? Color(white: 0.7) : Color(white: 0.3))
                                        
                                        if let location = locationService.currentLocation {
                                            Text("\(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))")
                                                .font(.system(size: 10))
                                                .foregroundColor(isDark ? Color.gray.opacity(0.6) : Color.gray.opacity(0.6))
                                        } else {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Location unavailable")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(isDark ? Color.orange.opacity(0.7) : Color.orange.opacity(0.7))
                                                
                                                Text("Status: \(locationService.authorizationStatus.description)")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(isDark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.5))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isDark ? Color(white: 0.2) : .white)
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                        
                        // Warning Card
                        if let station = displayStation, let warning = station.warning, warning.hasWarning {
                            WarningCard(warning: warning, isDark: isDark)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        }
                        
                        // Error State
                        if let error = trainService.error {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.orange)
                                
                                Text("Error Loading Data")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(isDark ? .white : .black)
                                
                                Text(error.localizedDescription)
                                    .font(.system(size: 14))
                                    .foregroundColor(isDark ? .gray : .gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                
                                Button("Retry") {
                                    Task {
                                        await trainService.fetchStations()
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(isDark ? Color.blue : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        // Loading State
                        else if trainService.isLoading && trainService.stations.isEmpty {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                
                                Text("Loading BART departures...")
                                    .font(.system(size: 16))
                                    .foregroundColor(isDark ? .gray : .gray)
                                
                                Text("Fetching real-time data from BART API")
                                    .font(.system(size: 12))
                                    .foregroundColor(isDark ? Color.gray.opacity(0.7) : Color.gray.opacity(0.7))
                                    .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        // Platform Cards - Nearest Station Only
                        else {
                            if let station = displayStation {
                                VStack(spacing: 16) {
                                    ForEach(station.platforms) { platform in
                                        PlatformCard(platform: platform, isDark: isDark)
                                    }
                                }
                                .padding(.horizontal, 16)
                            } else {
                                // No location or station data
                                VStack(spacing: 16) {
                                    Image(systemName: "location.slash")
                                        .font(.system(size: 48))
                                        .foregroundColor(isDark ? .gray : .gray)
                                    
                                    Text("Location Required")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(isDark ? .white : .black)
                                    
                                    Text("Enable location services to find your nearest BART station")
                                        .font(.system(size: 14))
                                        .foregroundColor(isDark ? .gray : .gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        
                        // Last Updated
                        if let station = displayStation {
                            Text("Updated \(station.lastUpdatedString)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 24)
                                .padding(.bottom, 40) // Bottom padding for safe area
                        }
                    }
                }
            }
            .scrollIndicators(.visible)
            
            // Theme Toggle
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isDark.toggle()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isDark ? "sun.max.fill" : "moon.fill")
                            Text(isDark ? "Light" : "Dark")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isDark ? .white : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isDark ? Color(white: 0.2) : .white)
                        .cornerRadius(20)
                        .shadow(radius: 8)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                Spacer()
            }
        }
        .task {
            locationService.requestAuthorization()
            locationService.startLocationUpdates()
            
            // Wait for location to be available (up to 10 seconds)
            var waitCount = 0
            while locationService.currentLocation == nil && waitCount < 20 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                waitCount += 1
            }
            
            if let location = locationService.currentLocation {
                print("✅ Location obtained: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                print("✅ Location accuracy: \(location.horizontalAccuracy) meters")
                print("✅ Location timestamp: \(location.timestamp)")
            } else {
                print("⚠️ Location not available after waiting")
                print("⚠️ Authorization status: \(locationService.authorizationStatus.rawValue)")
            }
            
            await trainService.fetchStations()
        }
        .onChange(of: locationService.currentLocation) { oldLocation, newLocation in
            // When location updates, refresh to get nearest station
            if let newLocation = newLocation {
                print("🔄 Location updated: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
                Task {
                    await trainService.fetchStations()
                }
            }
        }
        .onChange(of: locationService.authorizationStatus) { oldStatus, newStatus in
            print("🔄 Authorization status changed: \(oldStatus.rawValue) -> \(newStatus.rawValue)")
            if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                locationService.startLocationUpdates()
            }
        }
    }
    
    private var displayStation: Station? {
        trainService.nearestStation
    }
}


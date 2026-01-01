import SwiftUI

struct ContentView: View {
    @StateObject private var trainService: TrainService
    @StateObject private var locationService: LocationService
    @State private var selectedView: ViewType = .closest
    @State private var isDark = false
    @State private var isRefreshing = false
    
    enum ViewType {
        case closest
        case all
    }
    
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
            
            ScrollView {
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
                                        if let location = locationService.currentLocation {
                                            trainService.updateNearestStation(with: location)
                                        }
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
                                    
                                    Text("Using current location")
                                        .font(.system(size: 14))
                                        .foregroundColor(isDark ? Color(white: 0.7) : Color(white: 0.3))
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
                        
                        // Segmented Control
                        HStack(spacing: 8) {
                            SegmentedButton(
                                title: "Closest station",
                                isSelected: selectedView == .closest,
                                isDark: isDark,
                                action: { selectedView = .closest }
                            )
                            
                            SegmentedButton(
                                title: "All stations",
                                isSelected: selectedView == .all,
                                isDark: isDark,
                                action: { selectedView = .all }
                            )
                        }
                        .padding(.horizontal, 16)
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
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        // Platform Cards or All Stations
                        else if selectedView == .closest {
                            if let station = displayStation {
                                VStack(spacing: 16) {
                                    ForEach(station.platforms) { platform in
                                        PlatformCard(platform: platform, isDark: isDark)
                                    }
                                }
                                .padding(.horizontal, 16)
                            } else if !trainService.stations.isEmpty {
                                // No nearest station but we have stations
                                Text("Enable location services to find nearest station")
                                    .font(.system(size: 14))
                                    .foregroundColor(isDark ? .gray : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                            } else {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                            }
                        } else {
                            if trainService.stations.isEmpty {
                                VStack(spacing: 16) {
                                    Text("No stations available")
                                        .font(.system(size: 16))
                                        .foregroundColor(isDark ? .gray : .gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(trainService.stations) { station in
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text(station.name)
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(isDark ? .white : .black)
                                                .padding(.horizontal, 16)
                                            
                                            ForEach(station.platforms) { platform in
                                                PlatformCard(platform: platform, isDark: isDark)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // Last Updated
                        if let station = displayStation {
                            Text("Updated \(station.lastUpdatedString)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 24)
                                .padding(.bottom, 100)
                        }
                    }
                }
            }
            
            // Bottom Navigation
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Divider()
                        .background(isDark ? Color(white: 0.2) : Color(white: 0.8))
                    
                    HStack {
                        BottomNavButton(
                            icon: "mappin.circle.fill",
                            title: "Nearby",
                            isSelected: true,
                            isDark: isDark
                        )
                        
                        Spacer()
                        
                        BottomNavButton(
                            icon: "heart.fill",
                            title: "Favorites",
                            isSelected: false,
                            isDark: isDark
                        )
                        
                        Spacer()
                        
                        BottomNavButton(
                            icon: "gearshape.fill",
                            title: "Settings",
                            isSelected: false,
                            isDark: isDark
                        )
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)
                    .background(isDark ? Color(white: 0.15) : .white)
                    
                    // Home Indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isDark ? Color(white: 0.2) : Color(white: 0.7))
                        .frame(width: 128, height: 4)
                        .padding(.bottom, 8)
                }
            }
            
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
            await trainService.fetchStations()
        }
        .onChange(of: locationService.currentLocation) { newLocation in
            if let location = newLocation {
                trainService.updateNearestStation(with: location)
            }
        }
    }
    
    private var displayStation: Station? {
        selectedView == .closest ? trainService.nearestStation : trainService.stations.first
    }
}

struct SegmentedButton: View {
    let title: String
    let isSelected: Bool
    let isDark: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? (isDark ? .white : .black) : (isDark ? .gray : .gray))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? (isDark ? Color(white: 0.2) : .white) : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct BottomNavButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let isDark: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? (isDark ? .blue : .blue) : (isDark ? .gray : .gray))
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isSelected ? (isDark ? .blue : .blue) : (isDark ? .gray : .gray))
        }
        .padding(.vertical, 8)
    }
}



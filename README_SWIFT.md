# Train Departure App - Swift/SwiftUI Version

This is a fully functional SwiftUI iOS app converted from the React/TypeScript version. The app displays real-time train departure information with location-based nearest station detection.

## Features

- ✅ **Real-time Data**: Fetches train departure information (currently using mock data that simulates real API calls)
- ✅ **Location Services**: Automatically finds the nearest train station based on your location
- ✅ **Dark Mode**: Full dark mode support with smooth transitions
- ✅ **Refresh Functionality**: Pull-to-refresh to update train schedules
- ✅ **Multiple Views**: Switch between "Closest station" and "All stations" views
- ✅ **Widget Support**: Includes Medium and Large widget views for iOS Home Screen
- ✅ **Warning System**: Displays service alerts and delays

## Project Structure

```
TrainDepartureApp/
├── Models/
│   ├── Train.swift          # Train data model
│   ├── Platform.swift       # Platform data model
│   └── Station.swift        # Station data model with location
├── Services/
│   ├── LocationService.swift  # CoreLocation wrapper for GPS
│   └── TrainService.swift     # Data fetching service (ready for API integration)
├── Views/
│   ├── ContentView.swift      # Main app view
│   ├── TrainRow.swift         # Individual train row component
│   ├── PlatformCard.swift    # Platform card with trains
│   ├── WarningCard.swift      # Service alert card
│   ├── MediumWidget.swift     # Medium widget (342×158)
│   └── LargeWidget.swift      # Large widget (342×354)
├── TrainDepartureApp.swift    # App entry point
└── Info.plist                 # Location permissions configuration
```

## Setup Instructions

### Option 1: Create New Xcode Project (Recommended)

1. Open Xcode
2. Create a new iOS App project:
   - Product Name: `TrainDepartureApp`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum iOS: 17.0

3. Copy all files from this directory into your Xcode project:
   - Drag the `Models`, `Services`, and `Views` folders into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Add to target: TrainDepartureApp

4. Add Location Services:
   - Open `Info.plist` in your project
   - Add the following keys (or use the provided Info.plist):
     - `NSLocationWhenInUseUsageDescription`: "This app needs your location to find the nearest train station."
     - `NSLocationAlwaysAndWhenInUseUsageDescription`: "This app needs your location to find the nearest train station."

5. Update `TrainDepartureApp.swift`:
   ```swift
   import SwiftUI
   
   @main
   struct TrainDepartureApp: App {
       var body: some Scene {
           WindowGroup {
               ContentView()
           }
       }
   }
   ```

6. Build and run!

### Option 2: Use Swift Package Manager

If you prefer a package-based approach, you can organize this as a Swift package, though for iOS apps, Xcode projects are recommended.

## API Integration

The app currently uses mock data that simulates real API responses. To integrate with a real transit API (e.g., BART API):

1. Open `TrainDepartureApp/Services/TrainService.swift`
2. Replace the `generateMockStations()` method with a real API call
3. Example BART API integration is commented in the file

### BART API Example

```swift
func fetchBARTStations() async throws -> [Station] {
    let url = URL(string: "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=all&key=YOUR_API_KEY")!
    let (data, _) = try await URLSession.shared.data(from: url)
    // Parse XML/JSON response and convert to Station models
    return stations
}
```

## Key Features Implemented

### Location Services
- Automatic location detection
- Distance calculation to nearest station
- Permission handling

### Data Management
- ObservableObject pattern for reactive updates
- Async/await for network calls
- Error handling

### UI Components
- All original React components converted to SwiftUI
- Dark mode support throughout
- Smooth animations and transitions
- Responsive layouts

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Location permissions (for nearest station feature)

## Next Steps

1. **Add Real API**: Replace mock data with actual transit API calls
2. **Add Widgets**: Implement iOS WidgetKit extensions for Home Screen widgets
3. **Add Favorites**: Implement the favorites functionality
4. **Add Settings**: Create settings screen for preferences
5. **Add Notifications**: Push notifications for favorite stations
6. **Add Maps**: Show station locations on a map

## Differences from React Version

- **Native iOS**: Built with SwiftUI for native iOS performance
- **Location Services**: Uses CoreLocation instead of web geolocation
- **Data Fetching**: Uses async/await instead of React hooks
- **State Management**: Uses ObservableObject instead of useState
- **Styling**: Uses SwiftUI modifiers instead of Tailwind classes

## License

Same as original project.


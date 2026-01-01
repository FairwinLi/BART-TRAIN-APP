# Quick Setup Guide

## Step-by-Step Xcode Setup

### 1. Create New Xcode Project

1. Open **Xcode**
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Configure:
   - **Product Name**: `TrainDepartureApp`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Minimum iOS**: 17.0
5. Choose a location and click **Create**

### 2. Add Files to Project

1. In Xcode, right-click on your project folder in the navigator
2. Select **Add Files to "TrainDepartureApp"...**
3. Navigate to the `TrainDepartureApp` folder in this directory
4. Select these folders:
   - `Models/`
   - `Services/`
   - `Views/`
5. Make sure:
   - ✅ "Copy items if needed" is **checked**
   - ✅ "Create groups" is selected
   - ✅ "Add to targets: TrainDepartureApp" is **checked**
6. Click **Add**

### 3. Add Individual Files

1. Add `TrainDepartureApp.swift`:
   - Right-click project → Add Files
   - Select `TrainDepartureApp/TrainDepartureApp.swift`
   - Make sure "Copy items if needed" is checked
   - Add to target

2. Add `Info.plist`:
   - Right-click project → Add Files
   - Select `TrainDepartureApp/Info.plist`
   - Make sure "Copy items if needed" is checked
   - Add to target

### 4. Update App Entry Point

Replace the contents of `TrainDepartureAppApp.swift` (or `App.swift`) with:

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

### 5. Configure Location Permissions

1. In Xcode, select your project in the navigator
2. Select the **TrainDepartureApp** target
3. Go to the **Info** tab
4. Under "Custom iOS Target Properties", add:
   - **Key**: `Privacy - Location When In Use Usage Description`
   - **Type**: String
   - **Value**: `This app needs your location to find the nearest train station.`

   OR simply ensure your `Info.plist` contains:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs your location to find the nearest train station.</string>
   ```

### 6. Build and Run

1. Select a simulator or connected device
2. Press **⌘R** or click the **Run** button
3. When prompted, allow location access in the simulator:
   - **Features → Location → Custom Location...**
   - Enter coordinates (e.g., San Leandro: 37.7219, -122.1608)

## Testing Location Services

### In Simulator:
1. **Features → Location → Custom Location...**
2. Enter: **Latitude**: `37.7219`, **Longitude**: `-122.1608` (San Leandro)
3. Click **OK**

### On Device:
- The app will request location permission on first launch
- Grant permission to see nearest station feature

## Troubleshooting

### "Cannot find 'ContentView' in scope"
- Make sure all files in the `Views/` folder are added to the target
- Check that `ContentView.swift` is included in "Compile Sources"

### Location not working
- Check Info.plist has location permission keys
- Verify location services are enabled in Settings
- In simulator, set a custom location

### Build errors
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Restart Xcode
- Check all Swift files are added to the target

## Next Steps

1. **Test the app**: Run it and verify location services work
2. **Add real API**: Replace mock data in `TrainService.swift`
3. **Customize**: Adjust colors, fonts, and layouts as needed
4. **Add features**: Implement favorites, settings, etc.

## File Structure After Setup

Your Xcode project should look like:

```
TrainDepartureApp
├── TrainDepartureApp
│   ├── TrainDepartureApp.swift
│   ├── Info.plist
│   ├── Models/
│   │   ├── Train.swift
│   │   ├── Platform.swift
│   │   └── Station.swift
│   ├── Services/
│   │   ├── LocationService.swift
│   │   └── TrainService.swift
│   └── Views/
│       ├── ContentView.swift
│       ├── TrainRow.swift
│       ├── PlatformCard.swift
│       ├── WarningCard.swift
│       ├── MediumWidget.swift
│       └── LargeWidget.swift
└── Assets.xcassets
```

That's it! Your app should now build and run. 🚀


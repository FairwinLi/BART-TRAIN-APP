# Quick Start - Run the App

## Method 1: Create New Xcode Project (Recommended)

### Step 1: Open Xcode and Create Project
1. Open **Xcode** (download from App Store if needed)
2. Click **File → New → Project** (or press `⌘⇧N`)
3. Select **iOS** tab → **App**
4. Click **Next**

### Step 2: Configure Project
- **Product Name**: `TrainDepartureApp`
- **Team**: (Select your Apple ID or leave default)
- **Organization Identifier**: `com.yourname` (or any identifier)
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: None
- **Minimum iOS**: **17.0**
- Click **Next**

### Step 3: Choose Location
- Select where to save your project
- **Uncheck** "Create Git repository" (optional)
- Click **Create**

### Step 4: Add Files to Project
1. In Xcode's left sidebar (Project Navigator), find your project folder
2. **Right-click** on the project name → **Add Files to "TrainDepartureApp"...**
3. Navigate to: `/Users/fairwin/Downloads/Train Departure App Design (2)/TrainDepartureApp`
4. Select **ALL** folders and files:
   - `Models/` folder
   - `Services/` folder
   - `Views/` folder
   - `TrainDepartureApp.swift`
   - `Info.plist`
5. Make sure these are checked:
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets: TrainDepartureApp**
6. Click **Add**

### Step 5: Replace Default App File
1. In Xcode, find `TrainDepartureAppApp.swift` (or `App.swift`) in the project
2. **Delete** it (right-click → Delete → Move to Trash)
3. The `TrainDepartureApp.swift` you just added will be the entry point

### Step 6: Configure Location Permissions
1. Click on your project name in the left sidebar
2. Select the **TrainDepartureApp** target
3. Click the **Info** tab
4. Under "Custom iOS Target Properties", click the **+** button
5. Add this key:
   - **Key**: `Privacy - Location When In Use Usage Description`
   - **Type**: String
   - **Value**: `This app needs your location to find the nearest train station.`

### Step 7: Build and Run! 🚀
1. Select a simulator (e.g., **iPhone 15 Pro**) from the device menu at the top
2. Press **⌘R** (or click the ▶️ Play button)
3. Wait for the app to build and launch in the simulator

### Step 8: Test Location (In Simulator)
1. Once the app launches, go to **Features → Location → Custom Location...**
2. Enter coordinates:
   - **Latitude**: `37.7219`
   - **Longitude**: `-122.1608`
   - (This is San Leandro, CA - near BART stations)
3. Click **OK**
4. The app will show the nearest station!

---

## Method 2: Open Existing Project (If Xcode Project Exists)

If you already have an Xcode project set up:

1. Open **Xcode**
2. **File → Open** (or `⌘O`)
3. Navigate to your `.xcodeproj` file
4. Select a simulator
5. Press **⌘R** to run

---

## Troubleshooting

### "Cannot find 'ContentView' in scope"
- Make sure all files in `Views/` folder are added to the target
- Check: Select a file → Right sidebar → Target Membership → ✅ TrainDepartureApp

### "Missing Info.plist"
- Make sure `Info.plist` is in your project
- Check it's added to the target

### Location not working
- In simulator: **Features → Location → Custom Location...**
- Set coordinates: `37.7219, -122.1608`

### Build errors
- **Product → Clean Build Folder** (`⇧⌘K`)
- Restart Xcode
- Make sure all Swift files are added to target

### "No such module 'SwiftUI'"
- Make sure you selected **SwiftUI** as the interface when creating the project
- Minimum iOS should be 17.0+

---

## What You Should See

When the app runs, you'll see:
- ✅ Station name at the top
- ✅ Distance from your location
- ✅ Segmented control (Closest station / All stations)
- ✅ Platform cards with train departures
- ✅ Dark/Light mode toggle button (top right)
- ✅ Bottom navigation bar

The app uses **mock data** that simulates real train schedules. To connect to a real API, see `README_SWIFT.md`.

---

## Need Help?

- Check `SETUP_GUIDE.md` for detailed instructions
- Check `README_SWIFT.md` for project documentation

Happy coding! 🎉


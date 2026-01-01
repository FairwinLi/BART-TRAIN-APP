# Step-by-Step Widget Setup Guide

## Overview
You need to create a **Widget Extension** target in Xcode to use widgets. This is a separate target from your main app.

## Step 1: Create Widget Extension Target

1. **Open Xcode** with your project

2. **Click your project name** (blue icon at top of left sidebar)

3. **Click the "+" button** at the bottom of the targets list (left side of the main area)

4. **Select "Widget Extension"** from the template chooser

5. **Click "Next"**

6. **Configure the extension:**
   - **Product Name**: `BARTDepartureWidget`
   - **Organization Identifier**: (same as your main app, or leave default)
   - **Include Configuration Intent**: **UNCHECKED** ✅ (we're using StaticConfiguration)
   - **Include Live Activities**: **UNCHECKED** ✅
   - **Language**: Swift

7. **Click "Finish"**

8. When asked **"Activate 'BARTDepartureWidget' scheme?"**, click **"Activate"**

## Step 2: Add Widget Files to Extension

### Add Medium Widget File

1. In Xcode, find the **`BARTDepartureWidget`** folder (created automatically)

2. **Right-click** on the `BARTDepartureWidget` folder

3. Select **"Add Files to 'BARTDepartureWidget'..."**

4. Navigate to: `/Users/fairwin/Downloads/Train Departure App Design (2)/BART DEPARTURE/BART DEPARTURE/Widgets/`

5. Select:
   - `BARTMediumWidget.swift`
   - `BARTDepartureWidget.swift` (if you want the large widget too)

6. Make sure:
   - ✅ **"Copy items if needed"** is checked
   - ✅ **"Create groups"** is selected
   - ✅ **"Add to targets: BARTDepartureWidget"** is checked

7. Click **"Add"**

### Delete Default Widget Files

1. In the `BARTDepartureWidget` folder, find:
   - `BARTDepartureWidget.swift` (the default one Xcode created)
   - OR `BARTDepartureWidgetBundle.swift`

2. **Delete** the default widget file(s) that Xcode created
   - Right-click → Delete → Move to Trash

3. Keep the widget files you just added

## Step 3: Create/Update Widget Bundle

1. In the `BARTDepartureWidget` folder, create a new file:
   - Right-click → New File
   - iOS → Swift File
   - Name: `BARTDepartureWidgetBundle.swift`

2. **Replace** the contents with:

```swift
import WidgetKit
import SwiftUI

@main
struct BARTDepartureWidgetBundle: WidgetBundle {
    var body: some Widget {
        BARTMediumWidget()     // Medium widget (3 closest trains)
        BARTDepartureWidget()  // Large widget (all platforms)
    }
}
```

## Step 4: Share Code Between App and Widget

The widget needs access to your models and services. Add these files to the widget target:

### Files to Share:

1. **Models folder** (all files):
   - `Train.swift`
   - `Platform.swift`
   - `Station.swift`

2. **Services**:
   - `BARTAPIService.swift`

3. **Views** (optional, if you want to reuse components):
   - `LargeWidget.swift` (for large widget)
   - `MediumWidget.swift` (if you want to use it in app)

### How to Add to Widget Target:

**Method 1: File Inspector**

1. Select a file (e.g., `Train.swift`)
2. In the **right sidebar**, find **"Target Membership"**
3. Check ✅ **BARTDepartureWidget**
4. Repeat for all files listed above

**Method 2: Add Files Again**

1. Right-click `BARTDepartureWidget` folder → Add Files
2. Navigate to your `Models/` and `Services/` folders
3. Select the files
4. Make sure:
   - ✅ "Copy items if needed" is **UNCHECKED** (reference, don't copy)
   - ✅ "Add to targets: BARTDepartureWidget" is **CHECKED**

## Step 5: Configure Widget Capabilities

1. **Select the `BARTDepartureWidget` target** (not the main app target)

2. Go to **"Signing & Capabilities"** tab

3. **Add Background Modes** (if not already there):
   - Click **"+ Capability"**
   - Add **"Background Modes"**
   - Check **"Location updates"** (if available)

4. Go to **"Info"** tab

5. **Add Location Permission**:
   - Click **"+"** button
   - Add: `Privacy - Location When In Use Usage Description`
   - Value: `This widget needs your location to find the nearest BART station.`

## Step 6: Build and Test

1. **Select the widget scheme**:
   - At the top of Xcode, next to the play button
   - Click the scheme dropdown
   - Select **"BARTDepartureWidget"**

2. **Select a simulator or device**

3. **Press ⌘R** (or click Play)

4. The widget will appear in the **Widget Gallery**

## Step 7: Add Widget to Home Screen

1. **In the simulator/device**, go to Home Screen

2. **Long-press** on an empty area

3. Tap the **"+"** button (top left)

4. **Search** for: **"BART Next Departures"** or **"BART Departures"**

5. **Select Medium** size (or Large if you want)

6. Tap **"Add Widget"**

7. The widget will appear on your Home Screen!

## Troubleshooting

### "Cannot find 'Station' in scope"
- Make sure `Station.swift` is added to the widget target
- Check Target Membership in File Inspector

### "Cannot find 'BARTAPIService' in scope"
- Make sure `BARTAPIService.swift` is added to the widget target
- Check Target Membership

### Widget shows "Location Required"
- Make sure the main app has location permission
- Widgets inherit permissions from the main app
- Go to Settings → Privacy → Location Services → BART DEPARTURE

### Widget not appearing in gallery
- Make sure you selected the **BARTDepartureWidget** scheme
- Clean build: **Product → Clean Build Folder** (⇧⌘K)
- Rebuild: **⌘B**

### Build errors about @main
- Make sure only ONE file has `@main` in the widget target
- The `BARTDepartureWidgetBundle.swift` should have `@main`
- Other widget files should NOT have `@main`

### Widget shows placeholder only
- This is normal when first added
- Wait a few seconds for the first update
- Pull down on the widget to refresh

## Quick Checklist

- [ ] Widget Extension target created
- [ ] Widget files added to extension
- [ ] Widget Bundle file created with @main
- [ ] Models added to widget target
- [ ] BARTAPIService added to widget target
- [ ] Location permission added to widget Info.plist
- [ ] Widget scheme selected
- [ ] Build successful
- [ ] Widget appears in gallery
- [ ] Widget added to Home Screen

## What You'll See

Once set up, the medium widget will show:
- Station name
- Next 3 closest train departures (across all platforms)
- Each train shows: line, destination, time, minutes
- Status bar at bottom (delays or "all normal")

The widget updates automatically every 2 minutes with fresh BART data!

---

**Need help?** Check the console for error messages and make sure all files are added to the widget target.


# Widget Setup Instructions

## What Was Created

I've created a **WidgetKit widget** that:
- ✅ Uses location to find your nearest BART station
- ✅ Fetches real-time departure data
- ✅ Displays as a **Large Widget** on your Home Screen
- ✅ Auto-refreshes every 2 minutes

## Setup Steps in Xcode

### 1. Add Widget Extension Target

1. In Xcode, click your **project name** (blue icon at top)
2. Click the **+** button at the bottom of the targets list
3. Select **Widget Extension**
4. Click **Next**
5. Configure:
   - **Product Name**: `BARTDepartureWidget`
   - **Include Configuration Intent**: **Unchecked** (we're using StaticConfiguration)
   - **Include Live Activities**: **Unchecked**
6. Click **Finish**
7. When asked "Activate 'BARTDepartureWidget' scheme?", click **Activate**

### 2. Replace Widget Files

1. In the new `BARTDepartureWidget` folder, **delete** the default widget files:
   - `BARTDepartureWidget.swift` (or similar)
   - `BARTDepartureWidgetBundle.swift` (if separate)

2. **Add** the new widget file:
   - Right-click `BARTDepartureWidget` folder → **Add Files to "BARTDepartureWidget"...**
   - Navigate to: `BART DEPARTURE/Widgets/BARTDepartureWidget.swift`
   - Make sure **"Copy items if needed"** is **checked**
   - Make sure **"Add to targets: BARTDepartureWidget"** is **checked**
   - Click **Add**

### 3. Share Code Between App and Widget

The widget needs access to your models and services. You have two options:

#### Option A: Add Files to Widget Target (Recommended)

1. Select these files in Xcode:
   - `Models/` folder (all files)
   - `Services/BARTAPIService.swift`
   - `Views/LargeWidget.swift` (and its sub-components)

2. In the right sidebar, under **Target Membership**, check:
   - ✅ **BART DEPARTURE** (main app)
   - ✅ **BARTDepartureWidget** (widget extension)

#### Option B: Create Shared Framework (Advanced)

Create a shared framework for models and services (more complex but better for larger projects).

### 4. Configure Widget Capabilities

1. Select the **BARTDepartureWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **Background Modes**
5. Check **Location updates** (if available)

### 5. Add Location Permission to Widget

1. Select **BARTDepartureWidget** target
2. Go to **Info** tab
3. Add location permission keys (same as main app):
   - `Privacy - Location When In Use Usage Description`
   - Value: `This widget needs your location to find the nearest BART station.`

### 6. Build and Test

1. Select **BARTDepartureWidget** scheme from the scheme menu
2. Select a simulator or device
3. Press **⌘R** to run
4. The widget will appear in the widget gallery

## Adding Widget to Home Screen

1. Long-press on Home Screen
2. Tap the **+** button (top left)
3. Search for **"BART Departures"**
4. Select **Large** size
5. Tap **Add Widget**
6. The widget will automatically:
   - Request location permission (if not already granted)
   - Find your nearest station
   - Display real-time departures

## Widget Features

- **Automatic Location**: Uses your current location to find nearest station
- **Real-time Data**: Fetches live BART departure times
- **Auto-refresh**: Updates every 2 minutes
- **Error Handling**: Shows helpful messages if location/data unavailable
- **Dark Mode**: Automatically adapts to system appearance

## Troubleshooting

### Widget shows "Location Required"
- Make sure the main app has location permission
- Widgets inherit permissions from the main app
- Go to Settings → Privacy → Location Services → BART DEPARTURE → Allow

### Widget not updating
- Widgets refresh on a schedule (every 2 minutes in this case)
- Pull down on the widget to force refresh
- Check that the widget has network access

### Build errors about missing types
- Make sure all model files are added to the widget target
- Check Target Membership in File Inspector (right sidebar)

### Widget shows placeholder only
- This is normal when first added
- Wait a few seconds for the first update
- Check that location services are enabled

## Notes

- Widgets run in a separate process from the main app
- Location access is inherited from the main app's permissions
- Widget updates are managed by iOS (not instant)
- The widget fetches data when iOS schedules an update


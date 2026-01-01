# Medium Widget Setup Guide

## What Was Created

I've created a **Medium Widget** (`BARTMediumWidget.swift`) that:
- ✅ Shows the **3 closest train times** across ALL platforms
- ✅ Uses location to find your nearest BART station
- ✅ Displays as a **Medium Widget** (342×158 pt)
- ✅ Auto-refreshes every 2 minutes
- ✅ Shows real-time delays from BART API

## Key Features

### Smart Train Selection
- Combines trains from **all platforms** at the station
- Sorts by arrival time (closest first)
- Shows the **top 3** regardless of which platform they're on

### Display Format
Each train shows:
- **Line badge** (colored)
- **Destination** name
- **Departure time** (e.g., "2:42 PM")
- **Minutes until arrival** (large, bold)
- **Delay status** (if delayed)

## Setup in Xcode

### Step 1: Add Widget Extension Target (if not already done)

1. In Xcode, click your **project name** (blue icon)
2. Click the **+** button at bottom of targets list
3. Select **Widget Extension**
4. Configure:
   - **Product Name**: `BARTDepartureWidget`
   - **Include Configuration Intent**: **Unchecked**
   - **Include Live Activities**: **Unchecked**
5. Click **Finish**

### Step 2: Add Medium Widget File

1. In the `BARTDepartureWidget` folder, add the new file:
   - Right-click folder → **Add Files to "BARTDepartureWidget"...**
   - Navigate to: `BART DEPARTURE/Widgets/BARTMediumWidget.swift`
   - Make sure **"Copy items if needed"** is checked
   - Make sure **"Add to targets: BARTDepartureWidget"** is checked
   - Click **Add**

### Step 3: Update Widget Bundle

1. Open `BARTDepartureWidgetBundle.swift` (or create it)
2. Update to include both widgets:

```swift
@main
struct BARTDepartureWidgetBundle: WidgetBundle {
    var body: some Widget {
        BARTDepartureWidget()  // Large widget
        BARTMediumWidget()     // Medium widget
    }
}
```

### Step 4: Share Code Between App and Widget

Make sure these files are added to **both** targets:
- `Models/` folder (all files)
- `Services/BARTAPIService.swift`
- `Views/LargeWidget.swift` (for large widget)
- `Views/MediumWidget.swift` (if you want to use it in app too)

**How to add to widget target:**
1. Select a file in Xcode
2. In right sidebar, under **Target Membership**
3. Check ✅ **BARTDepartureWidget**

### Step 5: Build and Test

1. Select **BARTDepartureWidget** scheme
2. Press **⌘R** to run
3. Widget will appear in widget gallery

## Adding to Home Screen

1. Long-press on Home Screen
2. Tap the **+** button
3. Search for **"BART Next Departures"**
4. Select **Medium** size
5. Tap **Add Widget**

## Widget Features

### What It Shows
- **Station name** at top
- **Next 3 Departures** section with:
  - Line color badge
  - Destination
  - Departure time
  - Minutes until arrival (large)
  - Delay status (if any)
- **Status bar** at bottom (delays or "All lines running normally")

### How It Works
1. Gets your current location
2. Finds nearest BART station
3. Fetches all trains from all platforms
4. Sorts by arrival time
5. Shows the 3 closest ones

## Example Display

```
Powell St
Nearest station • BART                   1:47 PM

Next 3 Departures
┌─────────────────────────────────┐
│ [RED] Millbrae                  │
│     1:50 PM                      │
│                         4 min    │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ [YELLOW] SF Airport              │
│     1:54 PM                      │
│                         8 min    │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ [GREEN] Daly City                │
│     2:00 PM • 5 min delay        │
│                         14 min   │
└─────────────────────────────────┘

✓ All lines running normally
```

## Troubleshooting

### Widget shows "Location Required"
- Make sure main app has location permission
- Widgets inherit permissions from main app
- Go to Settings → Privacy → Location Services → BART DEPARTURE

### Widget not updating
- Widgets refresh on iOS schedule (every 2 minutes in this case)
- Pull down on widget to force refresh
- Check that widget has network access

### Build errors about missing types
- Make sure all model files are added to widget target
- Check Target Membership in File Inspector

### Only shows 1-2 trains
- Station might not have many trains scheduled
- Check BART website for that station
- The widget shows up to 3, but will show fewer if that's all available

## Differences from Large Widget

- **Medium**: Shows 3 closest trains (all platforms combined)
- **Large**: Shows all platforms with multiple trains per platform
- **Medium**: More compact, focused on "what's next"
- **Large**: More detailed, shows platform organization

That's it! Your medium widget is ready to use. 🎉


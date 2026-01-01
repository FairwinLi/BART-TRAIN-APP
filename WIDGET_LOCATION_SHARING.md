# Sharing Location Between App and Widget

## Overview
Widgets cannot directly access location services. To use the user's actual location in widgets, we need to:
1. Set up App Groups (shared container)
2. Save location from the main app to shared UserDefaults
3. Read location from shared UserDefaults in the widget

## Step 1: Enable App Groups in Xcode

### For Main App Target:
1. Select your **BART DEPARTURE** project in Xcode
2. Select the **BART DEPARTURE** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **App Groups**
6. Click the **+** button to add a new App Group
7. Enter: `group.com.yourname.BARTDeparture` (replace `yourname` with your actual identifier)
   - Format must be: `group.` followed by reverse domain notation
   - Example: `group.com.johnsmith.BARTDeparture`
8. **Note the exact identifier** - you'll need to update it in code

### For Widget Target:
1. Select the **BART WIDGETExtension** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. **Use the SAME App Group identifier** as the main app
6. Check the box to enable it

**Important**: Both targets MUST use the same App Group identifier!

## Step 2: Update App Group Identifier in Code

1. Open `Services/SharedLocationManager.swift`
2. Find the line: `static let appGroupIdentifier = "group.com.yourname.BARTDeparture"`
3. Replace `group.com.yourname.BARTDeparture` with your actual App Group identifier from Step 1
4. Make sure it matches exactly (including the `group.` prefix)

## Step 3: Add SharedLocationManager to Both Targets

1. Select `Services/SharedLocationManager.swift` in Xcode
2. In the File Inspector (right sidebar), under **Target Membership**:
   - ✅ Check **BART DEPARTURE** (main app)
   - ✅ Check **BART WIDGETExtension** (widget)

## Step 4: Verify Code Changes

The code has already been updated:

✅ **LocationService.swift**: Now saves location to shared UserDefaults when location updates  
✅ **BART_WIDGET.swift**: Now reads location from shared UserDefaults instead of using default location

## Step 5: Test

1. Build and run the main app
2. Grant location permission when prompted
3. Wait for location to be received (check console logs)
4. Add the widget to your Home Screen
5. The widget should now show your actual nearest station!

## Troubleshooting

### Widget still shows default location
- Check that App Groups capability is enabled for **both** targets
- Verify the App Group identifier matches exactly in both Xcode and code
- Make sure `SharedLocationManager.swift` is included in both targets
- Check console logs in the main app - you should see "✅ Saved location to App Group"

### App Group identifier format
- Must start with `group.`
- Followed by reverse domain: `com.yourname.BARTDeparture`
- Example: `group.com.johnsmith.BARTDeparture`
- Must match exactly between Xcode capabilities and code

### Location not updating in widget
- Widgets only read location when they refresh (every 2 minutes)
- Pull down on the widget to force a refresh
- Location data expires after 5 minutes - main app needs to update it regularly

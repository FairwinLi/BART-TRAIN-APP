# Location Permission Setup Guide

## ✅ What's Already Done

Your app already has:
1. ✅ Location permission keys in `Info.plist`
2. ✅ `LocationService` that requests authorization
3. ✅ Code that calls `requestAuthorization()` when the app launches

## 🔧 Setup Steps in Xcode

### Step 1: Verify Info.plist Configuration

1. In Xcode, click your **project name** (blue icon, top of left sidebar)
2. Select the **BART DEPARTURE** target
3. Click the **Info** tab
4. Look for these keys under "Custom iOS Target Properties":
   - `Privacy - Location When In Use Usage Description`
   - Value should be: `This app needs your location to find the nearest train station.`

   **If these keys are missing:**
   - Click the **+** button
   - Add: `Privacy - Location When In Use Usage Description`
   - Type: String
   - Value: `This app needs your location to find the nearest train station.`

### Step 2: Verify the Code is Calling Request

The app already requests location in `ContentView.swift`:
```swift
.task {
    locationService.requestAuthorization()
    locationService.startLocationUpdates()
    // ...
}
```

This should automatically show the permission prompt when the app launches.

## 📱 How It Works

1. **On First Launch:**
   - App calls `requestAuthorization()`
   - iOS shows a system dialog: "BART DEPARTURE Would Like to Access Your Location"
   - User can choose "Allow While Using App" or "Don't Allow"

2. **If User Allows:**
   - Location services start
   - App finds nearest BART station
   - Displays real-time departures

3. **If User Denies:**
   - App shows error message
   - User can enable in Settings later

## 🧪 Testing Location Permission

### In Simulator:

1. **Reset Location & Privacy:**
   - Go to **Settings** app in simulator
   - **General → Reset → Reset Location & Privacy**
   - This clears previous permission choices

2. **Set a Custom Location:**
   - In simulator: **Features → Location → Custom Location...**
   - Enter coordinates:
     - **Latitude**: `37.7219`
     - **Longitude**: `-122.1608`
     - (This is San Leandro, CA - near BART stations)

3. **Run the App:**
   - The permission dialog should appear automatically
   - Tap **"Allow While Using App"**

### On Real Device:

1. **First Launch:**
   - Permission dialog appears automatically
   - Tap **"Allow While Using App"**

2. **If You Previously Denied:**
   - Go to **Settings → Privacy & Security → Location Services**
   - Find **BART DEPARTURE**
   - Change to **"While Using the App"**

## 🔍 Troubleshooting

### Permission Dialog Doesn't Appear

**Check:**
1. Info.plist has the permission key (see Step 1 above)
2. The key is spelled exactly: `NSLocationWhenInUseUsageDescription`
3. You're testing on a fresh install (not an app that already has permission)

**Fix:**
- Delete the app from simulator/device
- Clean build: **Product → Clean Build Folder** (⇧⌘K)
- Rebuild and run

### "Location Unavailable" Error

**Possible causes:**
1. Permission was denied
2. Location services are disabled system-wide
3. Simulator doesn't have location set

**Fix:**
- Check Settings → Privacy → Location Services
- Make sure Location Services is ON
- Make sure BART DEPARTURE has permission

### Permission Dialog Appears But Nothing Happens

**Check:**
- Look at Xcode console for errors
- Verify `LocationService` is properly initialized
- Make sure `requestAuthorization()` is being called

## 📝 Code Flow

```
App Launches
    ↓
ContentView appears
    ↓
.task modifier runs
    ↓
locationService.requestAuthorization()
    ↓
iOS shows permission dialog
    ↓
User allows/denies
    ↓
locationManagerDidChangeAuthorization() called
    ↓
If allowed: startLocationUpdates()
    ↓
Location updates received
    ↓
fetchStations() finds nearest station
```

## 🎯 Quick Test Checklist

- [ ] Info.plist has `NSLocationWhenInUseUsageDescription`
- [ ] App is deleted and reinstalled (fresh permission state)
- [ ] Location Services enabled in Settings
- [ ] Simulator has custom location set (if testing in simulator)
- [ ] Permission dialog appears on first launch
- [ ] After allowing, app shows nearest station

## 💡 Pro Tips

1. **Always test on a fresh install** - iOS won't show the dialog again if permission was already set
2. **Use simulator's custom location** - Great for testing different locations
3. **Check console logs** - Location errors will appear in Xcode console
4. **Test both allow and deny** - Make sure your error handling works

That's it! Your app should automatically request location permission on first launch. 🎉


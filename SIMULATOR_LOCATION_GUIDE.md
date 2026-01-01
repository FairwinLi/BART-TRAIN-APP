# iOS Simulator Location Guide

## Why Simulator Uses Different Location

**Yes, this is how Xcode/iOS Simulator works!** The simulator does NOT use your Mac's actual location. Instead, it uses:

1. **Default location** - Usually Apple's headquarters in Cupertino, CA
2. **Custom location** - If you set one in Features → Location
3. **The coordinates you're seeing (37.785834, -122.406417)** are very close to Powell St BART station

## How to Change Simulator Location

### Option 1: Set Custom Location (Recommended)

1. **In the Simulator**, go to: **Features → Location → Custom Location...**
2. Enter your **actual coordinates**:
   - **Latitude**: Your actual latitude
   - **Longitude**: Your actual longitude
3. Click **OK**
4. The app will now use those coordinates

### Option 2: Use Predefined Locations

**Features → Location** offers:
- **None** - No location (app will show location unavailable)
- **Apple** - Apple Park, Cupertino
- **City Bicycle Ride** - Simulated movement
- **City Run** - Simulated movement
- **Freeway Drive** - Simulated movement
- **Custom Location...** - Set your own coordinates

### Option 3: Find Your Actual Coordinates

To get your real coordinates:

1. **On iPhone**: Open Maps app → Tap your location dot → See coordinates
2. **On Mac**: Right-click in Maps → "Drop Pin" → See coordinates
3. **Online**: Go to Google Maps → Right-click your location → First number is lat, second is lon

## Why This Happens

- **Simulator = Simulated device** - It doesn't have GPS hardware
- **Real device = Actual GPS** - Uses your real location from GPS satellites
- The simulator needs you to manually set the location

## Your Current Coordinates

The coordinates you're seeing: **37.785834, -122.406417**

This is in **San Francisco, CA**, very close to:
- **Powell St BART**: 37.7849, -122.4074 (0.1 miles away)
- That's why Powell St shows as your closest station!

## Quick Fix

If you want to test with a different location:

1. **Features → Location → Custom Location...**
2. Enter coordinates for a different area (e.g., near a different BART station)
3. The app will automatically update to show the nearest station to those coordinates

## On Real Device

When you run this on a **real iPhone/iPad**:
- ✅ It will use your **actual GPS location**
- ✅ No need to set custom location
- ✅ Will show your truly nearest BART station

## Testing Different Locations

To test different scenarios:

**Near San Leandro:**
- Lat: `37.7219`
- Lon: `-122.1608`

**Near Bay Fair:**
- Lat: `37.6974`
- Lon: `-122.1261`

**Near Embarcadero:**
- Lat: `37.7930`
- Lon: `-122.3965`

Just set these in **Features → Location → Custom Location...** to test!

---

**TL;DR**: Yes, the simulator uses simulated locations, not your real location. Set a custom location in Features → Location if you want to test with different coordinates. On a real device, it will use your actual GPS location.


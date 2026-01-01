# How to Find "Privacy - Location When In Use Usage Description" in Xcode

## Step-by-Step Instructions

### Method 1: Using the Info Tab (Easiest)

1. **Open Xcode** and open your project

2. **Click your project name** in the left sidebar
   - Look for the blue icon at the very top
   - It should say "BART DEPARTURE" (or your project name)

3. **In the main area**, you'll see your project settings with tabs at the top:
   - General
   - Signing & Capabilities
   - Resource Tags
   - **Info** ← Click this one!

4. **Scroll down** to find "Custom iOS Target Properties"
   - This is a list of key-value pairs

5. **Look for** `Privacy - Location When In Use Usage Description`
   - If you see it, you're all set!
   - If you DON'T see it, continue to step 6

6. **To add it:**
   - Click the **+** button (usually at the bottom of the list, or top-right of the section)
   - Start typing: `Privacy` or `Location`
   - Select: **"Privacy - Location When In Use Usage Description"**
   - Set the **Value** to: `This app needs your location to find the nearest train station.`

### Method 2: Using Info.plist File Directly

1. **In the left sidebar** (Project Navigator), find `Info.plist`
   - It should be in your project folder

2. **Right-click** on `Info.plist` → **Open As** → **Source Code**

3. **Look for** this key:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs your location to find the nearest train station.</string>
   ```

4. **If it's missing**, add it:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs your location to find the nearest train station.</string>
   ```

### Visual Guide

```
Xcode Window
├── Left Sidebar (Project Navigator)
│   └── BART DEPARTURE (blue icon) ← Click this
│
└── Main Area (Right side)
    ├── [General] [Signing...] [Info] ← Click "Info" tab
    │
    └── Custom iOS Target Properties
        ├── Privacy - Location When In Use Usage Description
        │   └── Value: "This app needs your location..."
        │
        └── [Other keys...]
```

## Quick Check

**If you see this in the Info tab:**
- ✅ `Privacy - Location When In Use Usage Description` = "This app needs your location to find the nearest train station."

**Then you're good to go!**

## Common Issues

### "I don't see the Info tab"
- Make sure you clicked the **project name** (blue icon), not a file
- The tabs only appear when the project is selected

### "I don't see Custom iOS Target Properties"
- Make sure you're on the **Info** tab (not General or Signing)
- Scroll down - it might be below other sections

### "The key exists but has a different value"
- That's fine! Just make sure it has some description text
- You can change it to: `This app needs your location to find the nearest train station.`

## Alternative: Check Info.plist File

If you can't find it in the Info tab, check the actual file:

1. In Project Navigator, find `Info.plist`
2. Click it to open
3. Look for the location permission key
4. If missing, add it (see Method 2 above)

That's it! Once you verify or add this key, your app will be able to request location permission. 🎯


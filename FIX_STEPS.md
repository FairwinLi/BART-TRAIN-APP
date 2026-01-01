# Step-by-Step Fix for Info.plist Error

## Why This Happens
Modern Xcode (especially for SwiftUI apps) automatically generates/processes Info.plist. But if you also have Info.plist in "Copy Bundle Resources", Xcode tries to do both → conflict!

## Solution: Remove Info.plist from Copy Bundle Resources

### Step 1: Open Build Phases
1. In Xcode, click **"BART DEPARTURE"** (blue icon at top of left sidebar)
2. Make sure the **"BART DEPARTURE"** project is selected (not the target yet)
3. In the main area, you'll see tabs: **General**, **Signing & Capabilities**, **Resource Tags**, **Info**, **Build Settings**, **Build Phases**
4. Click the **"Build Phases"** tab

### Step 2: Find Copy Bundle Resources
1. In the Build Phases tab, you'll see several sections:
   - Compile Sources
   - Link Binary With Libraries
   - **Copy Bundle Resources** ← This one!
   - etc.
2. Click the triangle next to **"Copy Bundle Resources"** to expand it

### Step 3: Remove Info.plist
1. Look through the list of files in "Copy Bundle Resources"
2. Find **"Info.plist"** in the list
3. Click on **"Info.plist"** to select it
4. Press the **minus (-)** button at the bottom of that section
   - OR right-click on "Info.plist" → **Delete**

### Step 4: Verify Info.plist Settings
1. Click the **"Build Settings"** tab (next to Build Phases)
2. In the search bar at the top, type: `INFOPLIST_FILE`
3. Look at the value - it should say something like:
   - `BART DEPARTURE/Info.plist` 
   - OR be empty (which is fine for modern projects)

### Step 5: Add Location Permission (Alternative Method)
If you want to use Xcode's built-in method instead:

1. Click the **"Info"** tab (next to Build Settings)
2. Under "Custom iOS Target Properties", click the **+** button
3. Add:
   - **Key**: `Privacy - Location When In Use Usage Description`
   - **Type**: String
   - **Value**: `This app needs your location to find the nearest train station.`

### Step 6: Clean and Build
1. Press **⇧⌘K** (Shift + Command + K) to clean
2. Press **⌘B** (Command + B) to build

The error should be gone!

## If It Still Doesn't Work

Try this alternative:
1. Delete the Info.plist file from your project (right-click → Delete → Move to Trash)
2. In Build Settings, clear the `INFOPLIST_FILE` value (make it empty)
3. Add location permission in the **Info** tab as described in Step 5 above


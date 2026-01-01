# Fix Info.plist Conflict

## The Problem
Xcode is trying to both copy AND automatically generate Info.plist, causing a conflict.

## Solution: Remove Info.plist from Copy Bundle Resources

### Step 1: Remove Info.plist from Build Phases
1. In Xcode, click your **project name** (top of left sidebar)
2. Select the **BART DEPARTURE** target
3. Click the **Build Phases** tab
4. Expand **Copy Bundle Resources**
5. Find **Info.plist** in the list
6. Select it and click the **minus (-)** button to remove it
7. **DO NOT delete the file** - just remove it from this build phase

### Step 2: Configure Info.plist in Build Settings
1. Still in the target settings, click the **Build Settings** tab
2. Search for `INFOPLIST_FILE`
3. Make sure it points to: `BART DEPARTURE/Info.plist`
4. If it's empty or wrong, click the value and enter: `BART DEPARTURE/Info.plist`

### Step 3: Alternative - Use Xcode's Built-in Info Settings
If the above doesn't work, you can remove the Info.plist file entirely and use Xcode's built-in settings:

1. **Delete** the Info.plist file from the project (right-click → Delete → Move to Trash)
2. In **Build Settings**, clear the `INFOPLIST_FILE` value (set it to empty)
3. Go to the **Info** tab in target settings
4. Click the **+** button to add:
   - **Key**: `Privacy - Location When In Use Usage Description`
   - **Type**: String
   - **Value**: `This app needs your location to find the nearest train station.`

### Step 4: Clean and Rebuild
1. Press **⇧⌘K** (Clean Build Folder)
2. Press **⌘B** (Build)

This should fix the conflict!


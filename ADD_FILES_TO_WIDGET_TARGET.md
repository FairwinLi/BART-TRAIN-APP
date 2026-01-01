# How to Add Files to Widget Target - Quick Fix

## The Problem
The widget extension can't find the types it needs because the files aren't included in the widget target. You need to add them using "Target Membership".

## Step-by-Step Instructions

### Method 1: Using File Inspector (Recommended - One File at a Time)

1. **In Xcode, open the Project Navigator** (left sidebar)

2. **Select the file** you need to add (e.g., `Station.swift`)

3. **Open the File Inspector** (right sidebar - or press ⌥⌘1)

4. **Under "Target Membership"**, you'll see checkboxes:
   - ✅ `BART DEPARTURE` (your main app - should be checked)
   - ⬜ `BART WIDGETExtension` (your widget - **check this box!**)

5. **Check the box** for `BART WIDGETExtension`

6. **Repeat** for all files listed below

### Method 2: Select Multiple Files at Once

1. **Hold ⌘ (Command)** and click multiple files in the Project Navigator
2. **Open File Inspector** (⌥⌘1)
3. **Check "BART WIDGETExtension"** under Target Membership
4. All selected files will be added to the target

---

## Files That Need to Be Added

### Models (All Required)
Add these files from `BART DEPARTURE/BART DEPARTURE/Models/`:
- ✅ `Station.swift`
- ✅ `Platform.swift`
- ✅ `Train.swift`

### Services (Required)
Add this file from `BART DEPARTURE/BART DEPARTURE/Services/`:
- ✅ `BARTAPIService.swift`

### Views (Required for Widget Display)
Add these files from `BART DEPARTURE/BART DEPARTURE/Views/`:
- ✅ `LargeWidget.swift`
- ✅ `MediumWidget.swift`

---

## Quick Checklist

Go through each file and verify the Target Membership:

- [ ] `Models/Station.swift` → Check "BART WIDGETExtension"
- [ ] `Models/Platform.swift` → Check "BART WIDGETExtension"
- [ ] `Models/Train.swift` → Check "BART WIDGETExtension"
- [ ] `Services/BARTAPIService.swift` → Check "BART WIDGETExtension"
- [ ] `Views/LargeWidget.swift` → Check "BART WIDGETExtension"
- [ ] `Views/MediumWidget.swift` → Check "BART WIDGETExtension"

---

## Visual Guide

When you select a file, the File Inspector on the right should look like this:

```
┌─────────────────────────────┐
│ File Inspector              │
├─────────────────────────────┤
│ ...                         │
│                             │
│ Target Membership           │
│ ☑ BART DEPARTURE            │
│ ☑ BART WIDGETExtension      │  ← Check this!
│                             │
└─────────────────────────────┘
```

---

## After Adding Files

1. **Build** the widget target: Press **⌘B**
2. **Check** if errors are resolved
3. If you still see errors, make sure you added **all** the files listed above

---

## Troubleshooting

### "Cannot find type 'Station' in scope"
→ Make sure `Station.swift` has "BART WIDGETExtension" checked

### "Cannot find 'BARTAPIService' in scope"
→ Make sure `BARTAPIService.swift` has "BART WIDGETExtension" checked

### "Cannot find 'LargeWidget' in scope"
→ Make sure `LargeWidget.swift` has "BART WIDGETExtension" checked

### Still getting errors after adding files?
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Rebuild: **⌘B**

---

## Alternative: Select Files in Groups

You can select all files in a folder at once:

1. Click the **`Models` folder** in Project Navigator
2. Open File Inspector (⌥⌘1)
3. Check "BART WIDGETExtension" under Target Membership
4. This will add all `.swift` files in that folder to the target
5. Repeat for `Services/` and `Views/` folders

**Note:** Make sure you only select the files listed above, not ALL files (e.g., don't add `LocationService.swift` or `TrainService.swift` to the widget target - the widget doesn't need them).


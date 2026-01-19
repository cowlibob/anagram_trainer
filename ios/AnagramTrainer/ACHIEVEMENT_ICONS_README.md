# Achievement Icon Export Guide

This guide explains how to generate transparent PNG icons for Game Center achievements.

## Overview

I've created an `AchievementIconGenerator` utility that programmatically generates all 21 achievement icons with transparent backgrounds at the required sizes (1024x1024 and 512x512).

## Files Created

1. **AchievementIconGenerator.swift** - Core generator with icon definitions
2. **AchievementExportView.swift** - UI for exporting icons
3. This README

## How to Export Icons

### Option 1: Using the Export View (Recommended)

1. **Temporarily add the export view to your app**:
   - Open `MainMenuView.swift`
   - Add a navigation link somewhere (e.g., in the settings or as a debug option):
   ```swift
   NavigationLink("Export Achievement Icons") {
       AchievementExportView()
   }
   ```

2. **Run the app** on simulator or device

3. **Tap the export buttons**:
   - Tap "Export 1024x1024 Icons" first
   - Then tap "Export 512x512 Icons"

4. **Find the exported files**:
   - **On Simulator**:
     - Open Finder
     - Go to `~/Library/Developer/CoreSimulator/Devices/`
     - Find your device folder
     - Navigate to `data/Containers/Data/Application/[YOUR_APP]/Documents/AchievementIcons/`
   - **On Device**:
     - Open Files app
     - Browse to "On My iPhone" → AnagramTrainer → AchievementIcons
     - Or connect to Mac and use Finder to access files

5. **Upload to App Store Connect**:
   - Go to App Store Connect → Your App → Features → Game Center
   - For each achievement, upload both sizes

### Option 2: Using Xcode Previews

1. Open `AchievementIconGenerator.swift` in Xcode
2. Click the preview button to see all icons
3. Take screenshots at appropriate sizes (this won't give you transparent backgrounds though)

### Option 3: Programmatic Export (Advanced)

Add this code temporarily to your app's initialization or a debug button:

```swift
Button("Export Icons") {
    let documentsPath = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0]
    let exportDirectory = documentsPath.appendingPathComponent("AchievementIcons")

    do {
        // Export 1024x1024
        try AchievementIconGenerator.exportAllIcons(to: exportDirectory, size: 1024)

        // Export 512x512
        try AchievementIconGenerator.exportAllIcons(to: exportDirectory, size: 512)

        print("Icons exported to: \(exportDirectory.path)")
    } catch {
        print("Export failed: \(error)")
    }
}
```

## Icon Definitions

### Graduated Levels (5 icons)
- `graduated_level_5_1024x1024.png` - Star (cyan)
- `graduated_level_6_1024x1024.png` - Flame (green)
- `graduated_level_7_1024x1024.png` - Bolt (orange)
- `graduated_level_8_1024x1024.png` - Sparkles (blue)
- `graduated_level_9_1024x1024.png` - Crown (purple)

### Campaign Stages (8 icons)
- `campaign_stage_1_1024x1024.png` - Flame (orange) - Warm Up
- `campaign_stage_2_1024x1024.png` - Text box (green) - Endings
- `campaign_stage_3_1024x1024.png` - Text box (blue) - Beginnings
- `campaign_stage_4_1024x1024.png` - Duployan (purple) - Digraphs
- `campaign_stage_5_1024x1024.png` - A circle (red) - Vowels
- `campaign_stage_6_1024x1024.png` - ABC (teal) - Consonants
- `campaign_stage_7_1024x1024.png` - Text box (pink) - Trigraphs
- `campaign_stage_8_1024x1024.png` - Trophy (yellow) - Boss Level

### Campaign Complete (1 icon)
- `campaign_complete_1024x1024.png` - Medal (yellow)

### Word Lengths (7 icons)
- `first_word_3_1024x1024.png` through `first_word_9_1024x1024.png`
- Numbers 3-9 in colored circles

## Customizing Icons

To customize the appearance, edit `AchievementIconGenerator.swift`:

- **Change colors**: Modify the `color` field in icon configs
- **Change icons**: Update the `icon` field with different SF Symbol names
- **Change styling**: Edit the `AchievementIconView` body
- **Add gradients/shadows**: Modify the view styling

## Game Center Setup

After exporting, configure in App Store Connect:

1. Go to your app → Features → Game Center
2. Click "+" to add achievements
3. Use the achievement IDs from `GameCenterManager.swift`:
   - `lettershift_level_5` through `lettershift_level_9`
   - `lettershift_campaign_stage_1` through `lettershift_campaign_stage_8`
   - `lettershift_campaign_complete`
   - `lettershift_first_word_3` through `lettershift_first_word_9`
4. Upload both 1024x1024 and 512x512 versions
5. Set achievement points (suggested: 10-25 per achievement)
6. Write descriptions for each

## Troubleshooting

**Icons have white backgrounds instead of transparent:**
- Use Option 1 (Export View) - it uses UIGraphicsImageRenderer which supports transparency
- Don't use screenshots from Xcode previews (they don't preserve transparency)

**Can't find exported files:**
- Check the console output for the exact path
- On simulator, use Finder to navigate to CoreSimulator folder
- On device, use Files app or connect to Mac

**Export button doesn't work:**
- Make sure to run on a device/simulator, not just preview
- Check console for error messages
- Verify file permissions

## Notes

- All icons use SF Symbols for consistency
- Transparent backgrounds are supported
- Icons include subtle gradients and shadows for depth
- Colors match the game's existing color scheme
- Each icon is unique and visually distinct

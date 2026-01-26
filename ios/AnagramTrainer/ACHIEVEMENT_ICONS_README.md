# Achievement Icon Export Guide

This guide explains how to generate square PNG icons for Game Center achievements.

## Overview

I've created an `AchievementIconGenerator` utility that programmatically generates all 21 achievement icons as square images with gradient backgrounds at the required sizes (1024x1024 and 512x512).

**Important**: Per Apple's Human Interface Guidelines, achievement icons should be uploaded as square images. Game Center automatically applies a circular mask when displaying them. The icon and important visual elements are centered to ensure they remain visible after the circular clipping.

## Technical Specifications

All exported icons meet Game Center requirements:
- **Dimensions**: 512x512 or 1024x1024 pixels (square)
- **DPI**: 72 DPI (explicitly set in PNG metadata)
- **Color Space**: sRGB
- **Format**: PNG with solid gradient backgrounds
- **Content**: Centered to accommodate circular masking

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

3. **Export and save the icons**:
   - Tap "Export 1024x1024 Icons"
   - Tap "Share Folder" when export completes
   - Choose "Save to Files"
   - Navigate to iCloud Drive or "On My iPhone/iPad"
   - Create/select a folder named "LetterShift"
   - Tap "Save"
   - Repeat for "Export 512x512 Icons"

4. **Access the exported files**:
   - Open Files app
   - Navigate to where you saved the folders (iCloud Drive/LetterShift or On My iPhone/LetterShift)
   - You should see two folders: LetterShift_1024 and LetterShift_512

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
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("LetterShift_Icons")

    do {
        // Remove if exists
        try? FileManager.default.removeItem(at: tempDir)

        // Export 1024x1024
        try AchievementIconGenerator.exportAllIcons(to: tempDir.appendingPathComponent("1024"), size: 1024)

        // Export 512x512
        try AchievementIconGenerator.exportAllIcons(to: tempDir.appendingPathComponent("512"), size: 512)

        print("Icons exported to temp directory")
        // Then use share sheet to save to Files
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

**Icons appear off-center in Game Center:**
- Ensure you're uploading the square images, not cropped circular versions
- Game Center applies its own circular mask and centering

**Share button doesn't appear:**
- Wait for the export to complete (check the status message)
- The "Share Folder" button appears after successful export

**Can't find exported files:**
- Check where you saved the folder in the share sheet
- Look in Files app → iCloud Drive or "On My iPhone/iPad" → LetterShift
- Search for "LetterShift_1024" or "LetterShift_512" in Files app

**Export button doesn't work:**
- Make sure to run on a device/simulator, not just preview
- Check console for error messages
- Verify you have storage space available

## Notes

- All icons use SF Symbols for consistency
- Square images with gradient backgrounds (Game Center applies circular mask automatically)
- Icons include subtle gradients and shadows for depth
- Colors match the game's existing color scheme
- Each icon is unique and visually distinct
- Icons are centered to remain visible when Game Center applies its circular clipping

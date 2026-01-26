# Game Center Setup Guide

Quick reference for setting up Game Center leaderboards and achievements in App Store Connect.

## Leaderboards (2 total)

### 1. Campaign Leaderboard
- **Leaderboard ID**: `lettershift_campaign_scores`
- **Type**: Classic (All-Time)
- **Name**: Campaign High Scores
- **Score Format**: Integer
- **Sort Order**: High to Low
- **Score Range**: 0 to 10,000
- **Description**: Best campaign completion scores

### 2. Graduated Mode Leaderboard
- **Leaderboard ID**: `lettershift_graduated_scores`
- **Type**: Recurring (Weekly)
- **Name**: Weekly Play Scores
- **Score Format**: Integer
- **Sort Order**: High to Low
- **Score Range**: 0 to 100,000
- **Description**: Weekly session scores in graduated/play mode

## Achievements (21 total)

See `game_center_setup.csv` for complete list with:
- Achievement IDs
- Names
- Descriptions (pre-earned and earned)
- Point values
- Icon file names

### Quick Summary

**Graduated Levels (5)**: 10-30 points each
- lettershift_level_5 through lettershift_level_9

**Campaign Stages (8)**: 10-25 points each
- lettershift_campaign_stage_1 through lettershift_campaign_stage_8

**Campaign Complete (1)**: 50 points
- lettershift_campaign_complete

**Word Lengths (7)**: 5-20 points each
- lettershift_first_word_3 through lettershift_first_word_9

**Total Achievement Points**: 315

## Setup Process

### Via App Store Connect Web UI (Required)

1. Go to https://appstoreconnect.apple.com
2. Select your app → Features → Game Center
3. Click "+" to add leaderboard/achievement
4. Copy-paste from CSV/this file
5. Upload icons from `Documents/AchievementIcons/`

### Time-Saving Tips

1. **Open CSV in Excel/Numbers** - Have it side-by-side with App Store Connect
2. **Copy-paste descriptions** - Don't retype everything
3. **Batch upload icons** - Export all at once, upload as you create each achievement
4. **Use keyboard shortcuts**: Tab to next field, Command+V to paste
5. **Create achievements in ID order** - Easier to track what's done

### Estimated Time
- **Leaderboards**: ~5 minutes (2 leaderboards)
- **Achievements**: ~30 minutes (21 achievements)
- **Total**: ~35 minutes of clicking

## Alternative: Wait for Apple?

Apple has been promising better Game Center tooling for years. Current status:
- ❌ No CLI tool
- ❌ No bulk import
- ❌ Limited API support
- ✅ Only web UI works

## Icon Files Reference

All icons are exported with naming:
```
{achievement_id}_{size}x{size}.png
```

Example:
```
lettershift_level_5_1024x1024.png
lettershift_level_5_512x512.png
```

**Technical Specifications:**
- Format: PNG
- Dimensions: 512x512 or 1024x1024 pixels (square)
- DPI: 72 (Game Center requirement)
- Color Space: sRGB
- Background: Solid gradient (Game Center applies circular mask)

## Testing

After setup, achievements will appear in-app when:
1. You're signed in to Game Center
2. App is built with Game Center entitlement
3. Running on device (not all achievements work in simulator)

Use the "Game Center" section in Settings to view your achievements during testing.

## Notes

- Achievement points are just for show - they don't affect gameplay
- Hidden achievements won't show until earned (we set all to visible)
- Leaderboard scores can take a few minutes to appear in Game Center
- Weekly leaderboards reset every Monday 12:00 AM UTC

# Building the Anagram Trainer iOS App

## Current Status

All Swift source files have been created following modern SwiftUI best practices. The project structure is complete but requires an Xcode project file (.xcodeproj) to build and run.

## Option 1: Create Project in Xcode (Recommended)

1. Open Xcode
2. **File → New → Project**
3. Choose **iOS → App**
4. Project settings:
   - **Product Name**: AnagramTrainer
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Minimum Deployments**: iOS 16.0
   - **Location**: `/Users/james/Projects/anagram_trainer/AnagramTrainerIOS`

5. **Delete the default files** Xcode creates (ContentView.swift, AnagramTrainerApp.swift if duplicates)

6. **Add existing files to project**:
   - Right-click on `AnagramTrainer` folder in Xcode
   - Choose **Add Files to "AnagramTrainer"...**
   - Select all folders: `Models`, `ViewModels`, `Views`, `Persistence`
   - Make sure "Create groups" is selected
   - Click Add

7. **Add Resources folder**:
   - Right-click on `AnagramTrainer` folder
   - **Add Files to "AnagramTrainer"...**
   - Select `Resources` folder
   - Make sure "Create folder references" is selected (important!)
   - Click Add

8. **Build and Run**: Cmd+R to build and run in simulator

## Option 2: Install XcodeGen (Alternative)

```bash
# Install XcodeGen via Homebrew
brew install xcodegen

# Generate project from project.yml
cd /Users/james/Projects/anagram_trainer/AnagramTrainerIOS
xcodegen generate

# Build and run
xcodebuild -project AnagramTrainer.xcodeproj -scheme AnagramTrainer -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Project Files Created

✅ **Models** (5 files):
- `Dictionary.swift` - Word loading and filtering
- `TrainingMode.swift` - Game mode definitions
- `GameState.swift` - Current game state tracking
- `CampaignStage.swift` - 8-stage campaign definition
- `LeaderboardEntry.swift` - Leaderboard data model

✅ **ViewModels** (2 files):
- `GameViewModel.swift` - Game logic and state management
- `CampaignViewModel.swift` - Campaign progression logic

✅ **Views** (5 files):
- `MainMenuView.swift` - Main menu with navigation
- `GamePlayView.swift` - Gameplay screen with tap-to-select
- `TrainingMenuView.swift` - Training mode selection
- `CampaignView.swift` - Campaign mode UI
- `LeaderboardView.swift` - Top 10 scores display

✅ **Persistence**:
- `PersistenceManager.swift` - UserDefaults-based storage

✅ **Resources**:
- 7 dictionary text files (895KB total)

✅ **App Entry Point**:
- `AnagramTrainerApp.swift` - SwiftUI App protocol

✅ **Configuration**:
- `Info.plist` - App metadata
- `project.yml` - XcodeGen spec (if using XcodeGen)

## Next Steps

Please choose one of the options above to create the Xcode project file, then we can build and test the app in the simulator!

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AnagramTrainer** is an iOS anagram puzzle game with 8 training modes and a campaign system. Built with SwiftUI/Combine using MVVM architecture. Features speech recognition, Game Center leaderboards, and an innovative concentric circular button control system.

- **Bundle ID**: uk.co.cowlibob.lettershift
- **Deployment Target**: iOS 18.6
- **Language**: Swift 5.0
- **No external dependencies** - Uses only Apple frameworks

## Common Commands

### Building

```bash
# Build the app
xcodebuild -scheme AnagramTrainer -configuration Debug -sdk iphoneos build

# Build for simulator
xcodebuild -scheme AnagramTrainer -configuration Debug -sdk iphonesimulator build

# Clean build folder
xcodebuild clean -scheme AnagramTrainer
```

### Build and Run on Device

**IMPORTANT: After EVERY completed change**, test on the Piglet device using the automated build script:

```bash
./build-and-run-piglet.sh
```

This script will:
- Build the app for Piglet device
- Kill any running instance (ensures fresh start)
- Install the new build automatically
- Launch the app on the device

The script is pre-configured for device ID `00008101-000849E61A78001E` (Piglet running iOS 26.2).

**Use this script instead of manual Xcode builds** - it replicates Xcode's "Build and Run" behavior from the command line and ensures the latest changes are running.

### Running Tests
```bash
# Run unit tests
xcodebuild test -scheme AnagramTrainer -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run UI tests
xcodebuild test -scheme AnagramTrainer -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:AnagramTrainerUITests

# Run specific test
xcodebuild test -scheme AnagramTrainer -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:AnagramTrainerTests/AnagramTrainerTests/testExample
```

**Note**: Test coverage is currently minimal (placeholder tests only).

### Development in Xcode
Open `AnagramTrainer.xcodeproj` in Xcode. The project uses Xcode's modern file-system synchronized groups (no manual .pbxproj maintenance needed for most file operations).

## Architecture

### MVVM Structure

**Models** (`AnagramTrainer/Models/`):
- `GameState.swift` - Core game state with timer, guesses, cursor position
- `Dictionary.swift` - **Singleton** managing 60k+ word dictionary and validation
- `TrainingMode.swift` - 8 modes: Random, Graduated, Suffix, Prefix, Digraph, Trigraph, Vowel Cluster, Consonant Blend
- `CampaignStage.swift` - 8-stage campaign progression (Warm Up → Boss Level)
- `LeaderboardEntry.swift` - Score tracking with full attempt history

**ViewModels** (`AnagramTrainer/ViewModels/`):
- `GameViewModel.swift` - Training game logic, speech recognition, definition API
- `CampaignViewModel.swift` - Campaign progression, scoring algorithm (base 100 + time bonus)

**Views** (`AnagramTrainer/Views/`):
- Main screens: `MainMenuView`, `GamePlayView`, `CampaignView`, `LeaderboardView`, `TrainingMenuView`
- `Components/` - 19 reusable components including `ConcentricCircularButtons`

### Key Singletons

All managers are accessed via `.shared`:
- `Dictionary` - Pre-loaded word lists, anagram validation
- `ThemeManager` - Dynamic color theming per game mode
- `GameCenterManager` - Leaderboard ID: "lettershift_high_scores"
- `PersistenceManager` - UserDefaults-based persistence (no Core Data)
- `UserSettings` - User preferences (handedness for UI)
- `SpeechRecognitionManager` - Voice input with British English (en-GB)

### Data Flow

```
User Input (Tap/Voice/Keyboard)
  → GameState (Published properties)
  → ViewModel (ObservableObject)
  → View (SwiftUI observes changes)
  → PersistenceManager (saves progress)
```

## Critical Components

### Concentric Circular Buttons (`Views/Components/ConcentricCircularButtons.swift`)
**The most complex UI component** - Custom gesture-based control with three concentric zones:
- **Outer ring**: Submit word
- **Middle ring**: Clear word
- **Center circle**: Skip puzzle (hold-to-confirm)

Features:
- Compression animation on touch
- Handedness support (left/right corner positioning via UserSettings)
- Dynamic scaling based on screen size
- Curved text rendering along arcs
- Complex gesture recognition with radial distance calculations

When modifying: Test on multiple device sizes and both handedness settings.

### Speech Recognition (`Utils/SpeechRecognitionManager.swift`)
- Uses context-aware hints (valid anagrams) for improved accuracy
- Processes incrementally - only new letters sent to GameViewModel
- British English locale to match dictionary
- Requires microphone permission (set in Info.plist)

### Dictionary System (`Models/Dictionary.swift`)
- Loads on app launch from `Resources/dictionary.txt` (549KB)
- Anagram signature matching (sorted characters for O(1) lookup)
- Tracks used signatures to prevent puzzle repetition
- Specialized word lists per training mode (`suffix_words.txt`, etc.)
- Valid anagram detection beyond target word

### Theme System (`Utils/ThemeManager.swift`)
- Dynamic colors based on training mode
- Gradient backgrounds with HSB manipulation
- Colors propagated via SwiftUI environment
- Animated transitions (0.4s ease-in-out)
- Hidden dev view: Long-press MainMenuView title to access theme editor

### Responsive Layout (`Utils/View+Scaling.swift`)
- Dynamic scaling factor based on screen width (reference: iPhone 15 Pro @ 393pt)
- Adaptive layouts for short screens (< 600pt height)
- Use `.scaled(_:)` modifier on all font sizes and spacing
- iPad optimizations automatically applied

## Game Logic Details

### Campaign Scoring
```swift
// Base score: 100 points
// Time bonus: Up to 50 points for completing < 5 seconds
// Formula: 100 + min(50, max(0, 50 - (time - 5) * 2))
```

### Level Progression (Graduated Mode)
- Starts at 3 letters
- 3-word streak → level up (increases word length)
- Max length: 8 letters
- Failure resets streak but not level

### Campaign Stages
1. Warm Up (5 words, length 3)
2. Ramp Up (6 words, length 4)
3. Challenge (7 words, length 5)
4. Tough (8 words, length 5)
5. Hard Mode (9 words, length 5)
6. Expert (9 words, length 6)
7. Master (10 words, length 6)
8. Boss Level (10 words, length 6)

### Pause/Resume Behavior
- Timer pauses accurately (tracks pause duration)
- App backgrounding auto-pauses
- Campaign state persists via UserDefaults
- Can cancel campaign mid-session (confirmation required)

## Input Systems

### Three Input Methods
1. **Letter Buttons**: Multi-tap interface with position-based selection
2. **Physical Keyboard**: Arrow keys for cursor, Delete, Return to submit
3. **Voice**: Speech recognition with real-time feedback

### Cursor Management
- `GameState.cursorPosition` tracks insertion point
- Arrow keys move cursor (keyboard input)
- Backspace respects cursor position
- Voice input always appends

Implementation in `GamePlayView.swift:462` and `GameState.swift`.

## Persistence Strategy

**UserDefaults-based** (keys in `PersistenceManager`):
- `currentLevel` - Graduated mode progress
- `campaignProgress` - Current stage, score, attempt history
- `localLeaderboard` - Top 25 scores with full session data

**No database** - Simple key-value storage sufficient for current scope.

## Development Features

### Debug Tools
- `CampaignViewModel.skipToLastWord()` - Jump to Boss Level (DEBUG only)
- Theme developer view - Long-press MainMenuView title
- Test dictionary available in Resources

### Recent Git History Shows
- Concentric button redesign with compression animation
- Voice recognition accuracy improvements with context hints
- Campaign cancellation without score submission
- UI positioning fixes (guessed word moved above buttons)
- Handedness support for controls

## File Organization Notes

- Project uses Xcode's modern file-system synchronized root groups (objectVersion = 77)
- No manual .pbxproj maintenance for file additions
- Keep specialized word lists in `Resources/` with naming pattern `{mode}_words.txt`
- Assets managed in `Assets.xcassets`

## Important Implementation Patterns

### When Adding New Training Modes
1. Add case to `TrainingMode` enum
2. Create `{mode}_words.txt` in Resources
3. Update `Dictionary.words(for:level:)` method
4. Add theme colors to `ThemeManager.colors(for:)`
5. Update `TrainingMenuView` button

### When Modifying Game State
- Always use `@Published` properties for UI-observable changes
- Pause timer during modifications to avoid race conditions
- Test with app backgrounding/foregrounding
- Consider cursor position for text modifications

### When Working with GameCenter
- Test authentication flow (user may not be logged in)
- Leaderboard ID: "lettershift_high_scores"
- Score format: Int (total campaign score)
- Context data includes JSON of attempt history

### When Adjusting UI Layout
- Use `.scaled(_:)` for all dimensions (respects screen size)
- Test on iPhone SE (small), iPhone 15 Pro (reference), iPad
- Check both handedness settings for positioned elements
- Verify on short screens (< 600pt height)

## API Integrations

### Definition Fetching
- Endpoint: `https://api.dictionaryapi.dev/api/v2/entries/en/{word}`
- Used in `GameViewModel.fetchDefinition(for:)`
- Network calls are async/await
- Gracefully handles failures (shows "Definition unavailable")

## Entitlements Required
- Game Center (`AnagramTrainer.entitlements`)

## Speech Recognition Requirements
- Microphone usage description in Info.plist
- Speech recognition permission request
- On-device recognition capability declared

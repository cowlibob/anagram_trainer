# Changelog

## [Unreleased] - iOS Native App - 2025-12-28

### Added - iOS SwiftUI App
- **Campaign History Review**: Deep session tracking for local leaderboard entries.
    - Records word-by-word attempts including duration and outcome (Solved, Exact Match, Skillpped).
    - Added `CampaignHistoryView` with indigo-themed detailed breakdown.
    - Interactive chevrons in the local leaderboard to tap through to session history.
    - **UI Polish**: "Local" tab is now default; history entries use a semi-transparent glass style for clarity.
- **Voice Input Integration**: Added hands-free answering using Apple's Speech Framework.
    - **SpeechRecognitionManager**: On-device transcription for privacy and speed.
    - **Intelligent Input**: Processes speech incrementally, only adding new letters to the guess.
    - **Visual Feedback**: Pulsing red microphone indicator when actively listening.
    - **Privacy**: Automatic authorization handling and Info.plist usage descriptions.
    - **Simulator Safety**: Graceful error handling for missing audio input on the iOS Simulator.

## [Unreleased] - iOS Native App - 2025-12-27

### Fixed - iOS SwiftUI App
- **Background Theme Flicker**: Eliminated background color flicker during navigation swipe-back gestures by decentralizing theme management.
- **Robust Theme Animations**: Implemented a "Crossfade Strategy" in `MainMenuView` using an opacity-animated overlay layer, ensuring buttery smooth theme transitions even when button presses are cancelled.
- **Layering and Interaction**: Resolved an issue where theme overlays blocked menu interactions by optimizing `ZStack` layering and removing manual `zIndex` assignments.

### Changed - iOS SwiftUI App
- **Decentralized Theme Management**: Refactored `ThemeManager` to serve as a functional color utility, moving active theme state from a global singleton into the SwiftUI `Environment`.
- **Local Animation State**: Individual views now manage their own transient theme animations, preventing global state pollution and ensuring UI stability during navigation.
- **Environment-based Theming**: Introduced custom `EnvironmentKey`s (`themeBaseColor`, `themeDarkBaseColor`) for propagating view-specific themes down the hierarchy.
- **MenuBackgroundView**: Updated to be fully transparent, consuming its theme colors from the environment and allowing for rich, layered background effects.

## [Unreleased] - iOS Native App - 2025-12-17

### Added - iOS SwiftUI App
- **Training mode info popups**: Automatically displays details about letter groupings when entering a specialized training mode
  - Shows mode description and exact letter patterns (digraphs, clusters, etc.)
  - Interactive "(?)" button in the gameplay header to re-open the info dialog
  - Integrated `FlowLayout` for clean pattern display
- **Automatic definition fetching**: Game now automatically fetches word definitions the moment a round concludes (success or skip)
- **MenuButton unified component**: Created single reusable button component used across all views
  - Optional icon support for consistent icon placement
  - Optional badge support for displaying additional info
  - Optional "Current" indicator for showing active selection
  - Responsive sizing for iPhone vs iPad/Mac devices
- **iOS 26+ glass material effects**: Native glass appearance using `.regularMaterial` and `GlassEffectContainer`
  - Subtle lensing/frosting effect similar to native iOS controls
  - Removed colored shadows on iOS 26+ for cleaner appearance
- **Comprehensive dark mode support**:
  - Adaptive pink-to-burgundy gradient backgrounds (light vs dark)
  - Separate dark mode app icon (icon_logotype_only_dark.svg) with softer #EAE5E6 color
  - Semantic `.primary` color for text that adapts to light/dark mode
  - Darker letter colors in MenuBackgroundView for dark mode (RGB: 0.25, 0.1, 0.18)
- **Responsive design for all device sizes**:
  - Device detection using `UIDevice.current.userInterfaceIdiom` (.pad/.mac)
  - Larger fonts and spacing on iPad/Mac
  - Letter wrapping for words >5 letters on iPhone (minimum 2 per line)
  - Adaptive button padding and sizing

### Changed - iOS SwiftUI App
- **High-contrast Training Info**: Updated `ModeInfoView` tags to use solid backgrounds with white text for maximum readability
  - Added colored glow effects to mode icons
  - Changed Suffix Focus color from orange to red for better vibrancy
- **Performance optimization**: Changed MenuBackgroundView letters from transparent to opaque (#DE739F) for better rendering
- **Pre-iOS 26 button styling**: Unified all buttons to use `.ultraThinMaterial` with shadows instead of colored backgrounds
- **GameResultView**: Changed to use `.ultraThinMaterial` background on iOS 26+ for glass effect
- **CampaignResultView**: Now displays as fullscreen modal with transparent background
- **TrainingMenuView**: Redesigned from List to ScrollView+VStack layout with MenuButton components
- **All menu buttons**: Migrated to use unified MenuButton component (MainMenuView, GamePlayView, CampaignGameView, TrainingMenuView, GraduatedDifficultySelector)

### Fixed - iOS SwiftUI App
- **GameResultView layout stability**: Reserved fixed space for definitions to prevent "Next Word" button from jumping when text loads
- **Menu button tap area**: Resolved issue where buttons were only tappable on text/icons
  - Refactored `MenuButton` to use layered `HStack`s inside a `ZStack` for solid hit-testing
  - Added `.contentShape(Rectangle())` and a nearly transparent background to eliminate "hollow" areas
  - Disabled hit-testing on the decorative background letter grid to prevent interference
- **Button action handling**: Fixed broken actions after MenuButton refactor by making it a view instead of nested Button
- **Material layering**: Removed black overlay to allow material to properly blur underlying layers

## [Unreleased] - iOS Native App - 2025-12-08

### Added - iOS SwiftUI App
- **Hardware keyboard support** for all game modes (Quick Play, Training, Campaign):
  - Letter keys (A-Z) to add letters to guess
  - **Cursor-aware backspace** - removes letter to the left of cursor, not just the last letter
  - Left/Right arrows to move cursor position
  - Return/Enter to submit guess
  - Cross-platform support (iOS/iPadOS/macOS via Catalyst)
- **KeyboardInputHelper utility class** for shared keyboard logic across game modes
- **Animated letter matrix background** (MenuBackgroundView) across all screens
- **App icon** (LS logotype) added to main menu with gradient styling

### Changed - iOS SwiftUI App
- **Renamed "Random" mode to "Quick Play"** throughout the app
- **Complete visual redesign** with consistent pink gradient theme:
  - Applied MenuBackgroundView with animated letters to all screens
  - All text now bright white for readability over pink background
  - Updated "LetterShift" title with DIN Condensed font, letter spacing, and gradient
  - Split title into "Letter" and "Shift" with offset positioning
- **Navigation improvements**:
  - Fixed invisible back buttons (white tint, dark toolbar scheme)
  - Removed navigation bar backgrounds for seamless gradient appearance
  - Increased GamePlayView navigation title size (inline → large)
  - Transparent list backgrounds with `.scrollContentBackground(.hidden)`
- **Leaderboard redesign**:
  - Removed all white backgrounds
  - Changed to white text throughout
  - Left-aligned player names, right-aligned scores with spacer
  - Removed row separators for cleaner look
  - Updated empty state styling
- **MenuBackgroundView improvements**:
  - Consistent letter movement and visibility
  - Less distracting letters during gameplay
  - Configurable grid size, gap, scale, font size, and rotation duration

### Fixed - iOS SwiftUI App
- **Cursor-aware backspace** now correctly removes letter at cursor position instead of always removing from the end
- **Campaign mode keyboard input** - added missing `.focusable()` and `.focused()` modifiers
- **iOS 17+ compatibility** - updated deprecated `.onChange` syntax to modern form

### Technical - iOS SwiftUI App
- Added `@FocusState` for keyboard input management
- Implemented hidden TextField for reliable keyboard capture
- Added `.onKeyPress` modifier for special keys (arrows, backspace, return)
- Created `KeyboardInputHelper` utility class with guess-to-scrambled position mapping logic
- Updated color schemes across all views for consistency
- Updated all `.onChange` modifiers to iOS 17+ syntax

## [Unreleased] - iOS Native App - 2025-12-04

### Added - iOS SwiftUI App
- **Native iOS application** built with SwiftUI for iPhone and iPad
- **Interactive cursor insertion**: Tap within guess to position cursor, insert letters at specific positions
- **Letter toggle**: Tap used letters to remove them from guess
- **Anagram filtering**: Automatically skips near-duplicate words (e.g., "share" and "shear")
- **Animated blinking cursor** with Timer-based visibility for insertion point
- **All 8 training modes**: Random, Graduated, Suffix Focus, Prefix Focus, Digraphs, Trigraphs, Vowel Clusters, Consonant Blends
- **Campaign mode** with 16 progressive stages and scoring system
- **Local leaderboard** with persistent high scores
- **Tap-to-select interface**: Tap scrambled letters to build guess word
- **Dynamic letter sizing**: Automatically scales for words 7-9+ letters to fit screen
- **Definition fetching** from dictionaryapi.dev
- **UserDefaults persistence** for campaign progress and leaderboard
- **Timer tracking** for scoring bonuses
- **Inactivity Hint System**:
  - Automatically triggers after 15 seconds of inactivity
  - Rearranges letters to group pattern (suffix/prefix/cluster)
  - Animates pattern letters with bounce/scale effect
  - Resets on interaction or new word
- **Modern UI** with gradients, animations, and SwiftUI components

### Fixed - iOS App
- Skip/give up now shows correct word before advancing
- Campaign success displays result screen properly
- Quit campaign navigation returns to main menu
- Clear button resets grey letter status
- Repeated letters only dim tapped instance (position-based tracking)
- Long words fit on screen with responsive sizing
- MainMenuView import statement typo
- **Hint System Fixes**:
  - Hint persists until new word loads (doesn't disappear on tap)
  - Letters animate smoothly to new positions
  - Tapping hint letters adds correct character regardless of display position
  - Refactored letter buttons into standalone `LetterButtonView` component
- **Letter Toggle Fixes**:
  - Position-based tracking ensures tapped letter is the one that dims
  - Duplicate letters (e.g., multiple 'E's) now highlight individually
  - Tapping a used letter removes it from the guess
- **Timer improvements**: Timer freezes at exact completion time instead of continuing to tick
- **Mode switching**: Game state resets when switching between training modes
- **Campaign completion flow**: After submitting score, navigates to leaderboard with back button to main menu
- **Anagram validation**: Accepts any valid dictionary word using the same letters, not just the seeded word
- **Hint improvements**: Green character hint now hides when all letters are used in guess
- **Performance logging**: Console logs show guess validation time in milliseconds
- **Timer pause**: Timer pauses when app goes to background, resumes on foreground
- **Debug logging**: Target word logged to console when starting GamePlayView
- **Campaign quit**: Users can quit campaign without submitting score via Cancel button
- **Dictionary updates**: Added missing words (e.g., "scrub", "scrubs") to dictionary
- **Campaign resume fix**: Fixed spinner hang when resuming campaign with saved progress
- **Dictionary optimization**: Switched to Set for O(1) lookups and added detailed validation logging
- **Robust dictionary loading**: Improved whitespace trimming to handle inconsistent line endings (fixes "broth" rejection)
- **UI update fix**: Fixed issue where successful guesses didn't trigger result screen (explicit state assignment)
- **Valid anagram fix**: Fixed issue where valid anagrams (e.g. "SATIN" for "STAIN") were marked as failure in result screen
- **Definition accuracy**: Fetches definition for the submitted word instead of target word when they differ
- **Dictionary expansion**: Added user-reported missing words (e.g. "curbs", "satin", "broth", "throb")

### Refactored - iOS App
- Extracted all view components into separate files in `Views/Components/`:
  - `LetterButtonView`, `ScrambledWordView`, `GuessView`, `TimerView`, `CursorView`
  - `GameResultView`, `CampaignGameView`, `CampaignResultView`, `CampaignCompleteView`
  - `LeaderboardEntrySheet`, `LeaderboardRow`
- Cleaned up `GamePlayView.swift`, `CampaignView.swift`, and `LeaderboardView.swift`

### Technical Details - iOS
- **Architecture**: MVVM pattern with Combine
- **iOS Target**: iOS 16.0+
- **Components**: GameState, GameViewModel, CampaignViewModel, PersistenceManager
- **Views**: MainMenuView, GamePlayView, CampaignView, TrainingMenuView, LeaderboardView
- **Resources**: 7 dictionary text files bundled with app
- **Project location**: `ios/AnagramTrainer/`

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-11-29

### Added
- **Train Me Campaign Mode**:
  - 8-stage progressive campaign (Warm Up → Boss Level)
  - Scoring system with base points (100) and time bonuses (up to 150)
  - Top 10 leaderboard with player names and dates
  - Campaign progress saving and resume functionality
  - Stage-specific hints showing target patterns
  - Leaderboard entry on both completion and early exit
- **New Training Modes**:
  - **Digraphs**: Practice consonant pairs (TH, SH, CH, PH, WH)
  - **Trigraphs**: Train on consonant clusters (STR, THR, SHR, TCH, DGE)
  - **Vowel Clusters**: Focus on vowel combinations (IE, EA, OU, EE, OO)
  - **Consonant Blends**: Master consonant blends (ST, BL, BR, CL, FL)
- **Leaderboard Menu**: Dedicated menu option to view top 10 scores anytime
- **Pre-filtered Word Lists**: Generated optimized word lists for all new training modes

### Changed
- Refined cluster lists to top 5 most frequent patterns for better learning
- Updated vowel clusters to strict vowel-only pairs (replaced 'ay' with 'ee')
- Updated digraphs/trigraphs to consonant-only patterns for clearer categorization

### Fixed
- Date parsing in leaderboard now handles timezone offsets correctly
- Improved date display format (DD/MM/YYYY)

## [1.0.1] - 2025-11-25

### Added
- **WebAssembly (WASM) Support**:
  - Created web-based version running Ruby via ruby.wasm
  - Browser-based gameplay with localStorage persistence
  - Test pages for WASM functionality (`web/test.html`, `web/test-simple.html`)
  - Web UI with styling (`web/index.html`, `web/style.css`, `web/app.js`)
  - Dictionary and filtered word lists copied to web directory

### Changed
- Updated `Store` class to support both file-based and localStorage persistence
- Modified `Trainer` class to handle WASM platform detection
- Adapted async operations for WASM environment

### Fixed
- Resolved "async io not supported" error in WASM environment during level-up
- Fixed localStorage integration for campaign and level persistence

## [1.0.0] - 2025-11-25

### Added
- **Training Modes**:
  - **Graduated Difficulty**: Automatically increases word length as you improve.
  - **Suffix Focus**: Practice words ending in common suffixes (-ING, -TION, etc.).
  - **Prefix Focus**: Practice words starting with common prefixes (UN-, RE-, etc.).
- **Real-time Feedback**: Used letters are dimmed in the anagram as you type.
- **Dictionary Definitions**: Displays word definitions from dictionaryapi.dev after each round.
- **History Tracking**:
  - detailed report of solved/failed words.
  - Tracks time taken and number of attempts.
  - Filters out skipped words (0 attempts).
- **Persistence**:
  - Saves training level (word length) between sessions.
  - Saves game history to `data/history.json`.
- **Performance**:
  - Pre-computed filtered dictionaries for instant word selection in training modes.
  - Threaded generation script (`bin/generate_filtered_dictionaries.rb`).

### Changed
- **Navigation**:
  - `Esc` key now universally used to go back/stop (Stop Training -> Training Menu -> Main Menu -> Exit).
  - Instant menu selection (no need to press Enter).
- **Input**:
  - Added cursor navigation (Left/Right arrows) for editing guesses.
  - improved input validation (beeps on invalid characters).

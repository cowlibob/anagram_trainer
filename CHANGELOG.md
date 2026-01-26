# Changelog

## [Unreleased] - iOS Native App - 2026-01-26

### Added - iOS SwiftUI App
- **Swipe-to-Reveal Word History** in Graduated Difficulty Selector:
  - Per-level word history tracking with persistence
  - iOS-native swipe gestures with alternating directions (even rows swipe left, odd rows swipe right)
  - History button revealed on swipe without triggering navigation
  - Detailed word list with outcome icons (checkmark/star/arrow), points, and times
  - Staggered hint animation on first view showing swipeable rows
  - Expandable history list stays visible when tapped, closes on swipe back
- **Dual Leaderboards** with swipeable TabView:
  - Separate Play (weekly) and Campaign (all-time) leaderboards
  - Swipeable pages with indicator dots at bottom
  - Local/Global scope toggle for each leaderboard
  - Simplified titles ("Play" and "Campaign")
  - NavigationLink for local entries to view detailed session history
- **Automated Build Script** (`build-and-run-piglet.sh`):
  - One-command build and deploy to physical device
  - Automatically kills running app before installing
  - Replicates Xcode's "Build and Run" behavior from command line
  - Added to CLAUDE.md with strong recommendation to use after every change

### Changed - iOS SwiftUI App
- **Removed Graduated mode from Train menu** (still accessible via main menu Play button for better UX)
- **Training mode info overlay** now shows on every entry, not just when changing modes
- **Leaderboard titles** simplified and icons removed for cleaner appearance

### Fixed - iOS SwiftUI App
- **High-priority gesture handling** prevents navigation when swiping to reveal history
- **Achievement icon export** now includes proper 72 DPI metadata and uses share sheet for easy transfer
- **Swipe gesture state management** properly tracks and dismisses revealed buttons

## [Unreleased] - iOS Native App - 2026-01-19

### Added - iOS SwiftUI App
- **Dual Game Center Leaderboards**:
  - Separate leaderboards for Campaign (all-time high scores) and Play/Graduated (weekly scores)
  - Leaderboard IDs: `lettershift_campaign_scores` and `lettershift_graduated_scores`
  - Automatic score submission with detailed console logging
  - Trophy button in leaderboard view to access Game Center achievements
- **Comprehensive Achievement System** (20+ achievements):
  - Word length achievements (3-9 letters)
  - Letter-specific challenges (Q, X, Z words)
  - Speed achievements (10s, 30s, 60s)
  - Streak achievements (3, 5, 10 correct in a row)
  - Campaign completion achievements (stages 1-8, full campaign)
  - Graduated level achievements (Beginner through Master)
  - Rare achievements (100+ words, 500+ words, 1000+ words)
- **Achievement Icon Generator**:
  - SwiftUI-based generator for creating Game Center achievement icons
  - Renders Graduated Difficulty Selector views at different completion states
  - Export functionality with proper DPI metadata (72 DPI)
  - Share sheet integration for easy file transfer
  - Debug-only navigation from Main Menu
- **Game Center Setup Documentation**:
  - Added `game_center_setup.md` with detailed configuration instructions
  - Included `achievements.json` with complete achievement definitions
  - Leaderboard configuration reference

### Changed - iOS SwiftUI App
- **Play mode score tracking** now persists locally and submits to Game Center weekly leaderboard
- **AudioManager** initialized at app launch to ensure mute switch is respected from first sound

### Fixed - iOS SwiftUI App
- **Audio respects device mute switch** - sounds no longer play when mute switch is enabled
- **Audio volume** now properly follows device volume level

## [Unreleased] - iOS Native App - 2026-01-18

### Added - iOS SwiftUI App
- **Letter-Based Scoring System**:
  - Base points calculated by letter length (3-letter words: 30pts, 9-letter words: 90pts)
  - Time bonus: up to 50% extra points for fast completion (< 5 seconds)
  - Graduated mode session scoring tracks cumulative points
  - Play sessions submit weekly high scores to leaderboard
- **Shuffle Button**:
  - Tap to randomly rearrange scrambled letters
  - Helps discover new letter patterns
  - Visual button with shuffle icon in gameplay

### Changed - iOS SwiftUI App
- **Graduated Difficulty Selector** completely redesigned:
  - Side-by-side alternating layout (icon-left/text-right, text-left/icon-right)
  - Circular level icons with dotted progress rings
  - Unlock status and word count displayed per level
  - Confetti animation on level unlock
  - Five difficulty levels: Beginner (5), Warming Up (6), Getting Hot (7), Challenging (8), Master (9)
- **Placeholder text** changed from "Type here..." to "Tap letters to spell word"
- **UI spacing improvements** for better visual hierarchy

## [Unreleased] - iOS Native App - 2026-01-10/11

### Added - iOS SwiftUI App
- **Word Count Progression System** for Graduated mode:
  - Tracks completion count per word length (5-9 letters)
  - 20 words required to unlock next difficulty level
  - Persistent progress tracking across sessions
  - Visual progress indicators in difficulty selector
- **Animated Sine Wave Paths** in Graduated Difficulty Selector:
  - Meandering path connecting difficulty levels
  - Animated wave with proper amplitude envelope
  - Arc-length parameterization for smooth animation
  - Static end sections with smooth wave transition
  - Phase wrapping for continuous infinite scroll effect

### Changed - iOS SwiftUI App
- **Graduated Difficulty Selector** evolved through multiple design iterations:
  - Initial meandering path with circular progress indicators
  - Experimented with sine wave mathematics and animations
  - Final side-by-side layout (see 2026-01-18 changes)

## [Unreleased] - iOS Native App - 2026-01-06/07/10

### Added - iOS SwiftUI App
- **SpriteKit Background Implementation**:
  - Replaced SwiftUI MenuBackgroundView with SpriteMenuBackgroundView using SpriteKit
  - Calculated diagonal coverage to ensure letters extend beyond screen edges during rotation
  - Grid square sized at 2× diagonal distance for complete screen coverage
  - Eliminated edge gaps visible during rotation
  - Smoother performance with hardware-accelerated rendering
- **Sound Feedback**:
  - Success sound on correct answer
  - Failure sound on wrong answer or skip
  - AudioManager handles sound playback
  - Respects device mute switch and volume
- **Confetti Effects**:
  - Celebrates correct answers with confetti animation
  - Confetti on level unlock in Graduated mode
  - ConfettiView component with particle system
- **Handedness Option**:
  - Center/Left/Right positioning options for concentric circular buttons
  - Setting accessible from pause menu
  - Preference persisted via UserSettings

### Changed - iOS SwiftUI App
- **Comprehensive Dark Mode Support**:
  - Adaptive color schemes across all screens
  - Dark mode backgrounds and text colors
  - Theme-aware gradients and materials
  - Improved visibility in all lighting conditions

### Fixed - iOS SwiftUI App
- **Pause Menu** now correctly displays guessed words without letter duplication
- **Main Menu Color Flash** eliminated during navigation back from gameplay
- **Automatic Pause on Backgrounding** - game pauses when app goes to background
- **Dark Mode Popups** properly styled with correct backgrounds and text colors
- **Continuous Haptic Feedback** bug fixed - haptics no longer continue when app backgrounds during button hold
- **Popover Styling** unified with opaque white backgrounds and proper z-index layering

## [Unreleased] - iOS Native App - 2026-01-04/05

### Added - iOS SwiftUI App
- **Skip Button** in leaderboard entry sheet for faster score submission
- **Campaign Cancellation** without score submission - players can quit without adding incomplete runs to leaderboard

### Changed - iOS SwiftUI App
- **Guessed Word Positioning** moved above letter buttons to prevent finger obstruction during typing
- **Popover backgrounds** unified to opaque white for better readability

### Fixed - iOS SwiftUI App
- **Z-index layering** corrected to prevent UI elements from appearing beneath popups

## [Unreleased] - iOS Native App - 2025-12-29/30

### Added - iOS SwiftUI App
- **Concentric Circular Buttons**: Completely redesigned the game controls (Submit, Clear, Skip) into a compact, ergonomic corner cluster.
    - **Smart Positioning**: Automatically anchors to the bottom-right or bottom-left based on user handedness.
    - **Compression Animation**: Rings compress dynamically (down to 10pt) as the center button grows, maintaining visibility and context.
    - **Hold-to-Confirm Skip**: "SKIP" button requires a deliberate hold-and-release action to prevent accidental skips.
    - **Haptic Integration**: Distinctive feedback for "ready" state and successful trigger.
- **Handedness Support**:
    - Added "Left/Right Handed" toggle in the Pause menu.
    - Persists preference via `UserSettings` and seamlessly updates all UI components.
- **Simulation Tools**: Added `simulate_growth.py` to model and visualize animation curves for UI tuning.

### Fixed - iOS SwiftUI App
- **Animation Synchronization**: Fixed a "double-growth" bug where the center button outpaced the surrounding rings.
- **Input Latency**: Eliminated visual lag in the Skip button by removing conflicting explicit animations, ensuring lock-step frame updates.
- **Gesture Precision**: Fixed a coordinate space bug where touches were calculated from top-left, causing erratic "move away" cancellation behavior. Interaction is now center-relative and stable.
- **Ghost Voice Input**: Resolved a race condition where clearing the guess and stopping the microphone would cause the cleared letters to re-appear.

### Changed - iOS SwiftUI App
- **Smart Voice Context**: Integrated partial anagram matching and singular letter context to `SFSpeechRecognizer` for significantly higher accuracy.

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

# LetterShift

LetterShift is a native iOS/iPadOS/macOS anagram training application designed to improve your anagram solving skills. Whether you're a Scrabble enthusiast, a crossword puzzle solver, or just love word games, this app helps you recognize patterns and solve anagrams faster.

## Description

The aim of LetterShift is to provide a focused environment for practicing anagrams. It moves beyond simple "solve this word" gameplay by offering targeted training modes, real-time feedback, and difficulty progression. The app tracks your performance, allowing you to see your improvement over time.

## Features

- **Native SwiftUI interface** optimized for iOS, iPadOS, and macOS
- **Dark mode support** with adaptive colors and gradients
- **Glass material effects** on iOS 26+ for a modern, polished look
- **Responsive design** that adapts to iPhone, iPad, and Mac screen sizes
- **Hardware keyboard support** with cursor navigation and shortcuts
- **Interactive touch controls** - tap letters to build words, tap to position cursor
- **Animated backgrounds** with rotating letter matrix
- **Word definitions** powered by dictionaryapi.dev

## Game Modes

### 1. Try (Quick Play)
The classic mode. You are given random words from the dictionary to solve. Great for a quick warmup or casual play.

### 2. Train (Training Modes)
This is the core of the application, designed to build specific skills:

*   **Graduated Difficulty**: Starts with shorter words (5 letters) and automatically increases the length as you solve them correctly. Your level is saved between sessions, so you can pick up where you left off.
*   **Suffix Focus**: Trains you to recognize common suffixes like `-ING`, `-TION`, `-NESS`, etc. The app presents words ending in these suffixes to help you learn to "chunk" words mentally.
*   **Prefix Focus**: Similar to Suffix Focus, but targets common prefixes like `UN-`, `RE-`, `DIS-`, etc.
*   **Digraphs**: Practice recognizing consonant pairs like `TH`, `SH`, `CH`, `PH`, `WH`.
*   **Trigraphs**: Train on consonant clusters like `STR`, `THR`, `SHR`, `TCH`, `DGE`.
*   **Vowel Clusters**: Focus on common vowel combinations like `IE`, `EA`, `OU`, `EE`, `OO`.
*   **Consonant Blends**: Master common consonant blends like `ST`, `BL`, `BR`, `CL`, `FL`.

### 3. Test (Campaign)
A gamified campaign mode that takes you through all training categories in a progressive journey:

1. **Warm Up** - 5-letter words (5 words)
2. **Suffixes** - Common suffix patterns (5 words)
3. **Prefixes** - Common prefix patterns (5 words)
4. **Digraphs** - Consonant pairs (5 words)
5. **Vowel Clusters** - Vowel combinations (5 words)
6. **Consonant Blends** - Consonant blends (5 words)
7. **Trigraphs** - Consonant clusters (5 words)
8. **Boss Level** - 6-letter words (10 words)

**Features:**
*   **Scoring System**: Earn 100 base points per word, plus time bonuses up to 150 points for fast solves
*   **Leaderboard**: Top 10 scores with player names and dates
*   **Progress Saving**: Resume your campaign where you left off
*   **Stage Hints**: See the target patterns before each stage

### 4. Leaderboard
View the top 10 campaign scores with player names and completion dates.

## Controls

**Touch/Tap:**
- **Tap scrambled letters** to build your guess word
- **Tap within guess** to position cursor for insertion
- **Tap used letters** to remove them from your guess

**Hardware Keyboard:**
- **Type letters** (A-Z) to add to your guess
- **Backspace** to remove letter before cursor
- **Left/Right Arrows** to move cursor position
- **Return/Enter** to submit your guess
- **Esc** to give up on a word or navigate back

## Development

This application is built with **Swift** and **SwiftUI**. The iOS app is located in `ios/AnagramTrainer/`.

### Requirements
- **Xcode**: 15.0+
- **iOS**: 16.0+ (iPhone, iPad)
- **macOS**: 14.0+ (via Mac Catalyst)

### Project Structure
- **Architecture**: MVVM pattern with Combine
- **Views**: MainMenuView, GamePlayView, TrainingMenuView, CampaignView, LeaderboardView
- **Components**: Reusable UI components in `Views/Components/`
- **ViewModels**: GameViewModel, CampaignViewModel
- **Resources**: Dictionary files and app assets

### Contributing
Contributions are welcome! If you have ideas for new training modes, better algorithms, or UI improvements, please submit a Pull Request.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add some amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

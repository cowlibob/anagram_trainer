# Changelog

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

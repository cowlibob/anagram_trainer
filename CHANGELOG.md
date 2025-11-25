# Changelog

All notable changes to this project will be documented in this file.

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

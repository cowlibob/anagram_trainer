# Anagram Trainer iOS

A native iOS SwiftUI app for improving anagram solving skills, based on the Ruby/WASM anagram trainer prototype.

## Features

- **Multiple Game Modes**: Random play, targeted training modes, and progressive campaign
- **Training Categories**: Graduated difficulty, suffix/prefix focus, digraphs, trigraphs, vowel clusters, consonant blends
- **Campaign Mode**: 8-stage progressive journey with scoring and leaderboard
- **Persistence**: Save progress, levels, and campaign state
- **Offline-First**: All dictionary data bundled with app

## Technical Architecture

### MVVM Pattern

This app follows the Model-View-ViewModel (MVVM) architecture pattern, which is the recommended approach for SwiftUI applications in 2025.

**Benefits**:
- Separation of concerns between UI and business logic
- Testable view models
- Reactive data binding via Combine framework
- Clean, maintainable code structure

**How it works**:
- **Models**: Pure data structures (structs) representing game entities
- **ViewModels**: ObservableObject classes managing state and business logic
- **Views**: SwiftUI views that observe and react to ViewModel changes

### Modern Swift/SwiftUI Techniques

#### 1. NavigationStack (iOS 16+)
**What**: Modern navigation API replacing NavigationView
**Why**: Type-safe navigation, better performance, deep linking support
**How**: Use `NavigationStack` with `navigationDestination` modifiers

#### 2. ObservableObject & @Published
**What**: Combine framework integration for reactive state management
**Why**: Automatic UI updates when state changes, no manual refresh needed
**How**: ViewModels conform to ObservableObject, use @Published for observed properties

```swift
class GameViewModel: ObservableObject {
    @Published var currentWord: String = ""
    @Published var score: Int = 0
}
```

#### 3. @AppStorage Property Wrapper
**What**: Property wrapper for UserDefaults persistence
**Why**: Declarative persistence, automatic synchronization, type-safe
**How**: Use `@AppStorage("key")` for simple value persistence

```swift
@AppStorage("currentLevel") private var currentLevel: Int = 5
```

#### 4. Codable Protocol
**What**: Built-in Swift protocol for serialization
**Why**: Type-safe JSON encoding/decoding, no third-party dependencies
**How**: Make models conform to Codable, use JSONEncoder/JSONDecoder

```swift
struct LeaderboardEntry: Codable {
    let playerName: String
    let score: Int
    let date: Date
}
```

#### 5. Structured Concurrency (async/await)
**What**: Modern asynchronous programming in Swift
**Why**: Easier to read/write than closures, built-in cancellation support
**How**: Mark functions with `async`, call with `await`, use `Task` for background work

```swift
func fetchDefinition(for word: String) async throws -> String {
    let (data, _) = try await URLSession.shared.data(from: url)
    return parseDefinition(data)
}
```

#### 6. Value Semantics with Structs
**What**: Using structs instead of classes for models
**Why**: Immutability, predictable copying, thread-safe
**How**: Define models as structs, not classes (unless need reference semantics)

#### 7. SF Symbols
**What**: Apple's built-in icon system
**Why**: Consistent design, automatic dark mode, accessibility support
**How**: Use `Image(systemName:)` with symbol names

#### 8. Environment Objects
**What**: Dependency injection for SwiftUI
**Why**: Share objects across view hierarchy without manual passing
**How**: Use `.environmentObject()` modifier and `@EnvironmentObject` property wrapper

### Persistence Strategy

**Approach**: UserDefaults with Codable for all persistent data

**Why UserDefaults**:
- Simple, reliable, built-into iOS
- Perfect for small data sets (< 1MB)
- Automatic synchronization
- No schema migration needed

**Alternatives Considered**:
- **Core Data**: Too heavy for this app's needs, adds complexity
- **SwiftData**: Requires iOS 17+, might limit device compatibility
- **File System**: UserDefaults is cleaner for structured data

**What's Persisted**:
- Current training level
- Campaign progress (stage, score, words remaining)
- Leaderboard entries (top 10)
- Session history (optional, for future)

### Dictionary Loading Strategy

**Approach**: Bundle text files with app, load on first launch

**Why**:
- Offline-first, works without network
- Fast lookup, no API rate limits
- Pre-filtered word lists for performance
- ~1MB app size increase (acceptable for modern devices)

**How**:
1. Copy all `.txt` files from `data/` to Xcode project
2. Use `Bundle.main.url(forResource:withExtension:)` to locate files
3. Load into memory as arrays of strings
4. Cache in Dictionary singleton for reuse

### App Lifecycle

**Modern Approach**: SwiftUI App protocol (no AppDelegate/SceneDelegate)

**Why**:
- Declarative lifecycle management
- Less boilerplate code
- SwiftUI-native approach
- Easier to understand and maintain

**How**:
```swift
@main
struct AnagramTrainerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Dictionary.shared)
        }
    }
}
```

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Project Structure

```
AnagramTrainer/
├── Models/
│   ├── Dictionary.swift
│   ├── TrainingMode.swift
│   ├── GameState.swift
│   ├── CampaignStage.swift
│   └── LeaderboardEntry.swift
├── ViewModels/
│   ├── GameViewModel.swift
│   └── CampaignViewModel.swift
├── Views/
│   ├── MainMenuView.swift
│   ├── GamePlayView.swift
│   ├── TrainingMenuView.swift
│   ├── CampaignView.swift
│   ├── LeaderboardView.swift
│   └── SessionReportView.swift
├── Persistence/
│   └── PersistenceManager.swift
├── Resources/
│   ├── dictionary.txt
│   ├── suffix_words.txt
│   ├── prefix_words.txt
│   ├── digraph_words.txt
│   ├── trigraph_words.txt
│   ├── vowel_cluster_words.txt
│   └── consonant_blend_words.txt
└── AnagramTrainerApp.swift
```

## Building

```bash
xcodebuild -project AnagramTrainer.xcodeproj -scheme AnagramTrainer -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Running

```bash
xcodebuild -project AnagramTrainer.xcodeproj -scheme AnagramTrainer -destination 'platform=iOS Simulator,name=iPhone 15'
```

## License

MIT License - Same as the original Ruby/WASM version

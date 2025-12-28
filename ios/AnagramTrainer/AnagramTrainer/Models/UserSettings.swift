import SwiftUI
import Combine

enum Handedness: String, CaseIterable, Identifiable {
    case left = "Left"
    case right = "Right"
    
    var id: String { self.rawValue }
}

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var handedness: Handedness = .right {
        didSet {
            UserDefaults.standard.set(handedness.rawValue, forKey: "user_handedness")
        }
    }
    
    private init() {
        let savedValue = UserDefaults.standard.string(forKey: "user_handedness") ?? Handedness.right.rawValue
        self.handedness = Handedness(rawValue: savedValue) ?? .right
    }
}

//
//  AnagramTrainerApp.swift
//  AnagramTrainer
//
//  Created by James Cowlishaw on 29/11/2025.
//

import SwiftUI

@main
struct AnagramTrainerApp: App {
    init() {
        // Pre-load dictionary on app launch
        _ = Dictionary.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}

import AVFoundation
import AudioToolbox

/// Manages audio playback with proper audio session configuration
/// to respect volume buttons and mute switch
final class AudioManager {
    static let shared = AudioManager()

    private init() {
        configureAudioSession()
    }

    /// Configure audio session to respect mute switch and volume buttons
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Use .ambient category which:
            // - Respects the silent/mute switch
            // - Respects the volume buttons
            // - Mixes with other audio (music, etc.)
            // - Is appropriate for UI sound effects
            try audioSession.setCategory(.ambient, mode: .default)
            try audioSession.setActive(true)
        } catch {
            // If audio session configuration fails, sounds will still play
            // but may not respect mute switch properly
            print("Failed to configure audio session: \(error)")
        }
    }

    /// Play sound for letter button taps
    /// Uses system keyboard tap sound (1104)
    func playLetterTap() {
        AudioServicesPlaySystemSound(1104)
    }

    /// Play sound for submit action
    /// Uses mail sent sound (1111)
    func playSubmit() {
        AudioServicesPlaySystemSound(1111)
    }

    /// Play sound for skip action
    /// Uses swoosh sound (1053)
    func playSkip() {
        AudioServicesPlaySystemSound(1053)
    }

    /// Play sound for clear action
    /// Uses keyboard delete sound (1155)
    func playClear() {
        AudioServicesPlaySystemSound(1155)
    }
}

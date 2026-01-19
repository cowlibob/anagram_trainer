import AVFoundation
import AudioToolbox
import UIKit

/// Manages audio playback with proper audio session configuration
/// to respect volume buttons and mute switch
final class AudioManager {
    static let shared = AudioManager()

    private var audioPlayer: AVAudioPlayer?

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

    /// Check if device output volume is effectively zero
    /// This respects both the mute switch and volume slider
    private var isMuted: Bool {
        let volume = AVAudioSession.sharedInstance().outputVolume
        return volume <= 0.0
    }

    /// Play sound only if device is not muted and volume is up
    /// Falls back to haptic feedback when muted
    private func playSystemSoundIfAllowed(_ soundID: SystemSoundID, hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        if isMuted {
            // Device is muted or volume is zero - only provide haptic feedback
            UIImpactFeedbackGenerator(style: hapticStyle).impactOccurred()
        } else {
            // Play sound at device volume
            AudioServicesPlaySystemSound(soundID)
        }
    }

    /// Play sound for letter button taps
    /// Uses system keyboard tap sound (1104)
    func playLetterTap() {
        playSystemSoundIfAllowed(1104, hapticStyle: .light)
    }

    /// Play sound for submit action
    /// Uses mail sent sound (1111)
    func playSubmit() {
        playSystemSoundIfAllowed(1111, hapticStyle: .medium)
    }

    /// Play sound for skip action
    /// Uses swoosh sound (1053)
    func playSkip() {
        playSystemSoundIfAllowed(1053, hapticStyle: .medium)
    }

    /// Play sound for clear action
    /// Uses keyboard delete sound (1155)
    func playClear() {
        playSystemSoundIfAllowed(1155, hapticStyle: .light)
    }
}

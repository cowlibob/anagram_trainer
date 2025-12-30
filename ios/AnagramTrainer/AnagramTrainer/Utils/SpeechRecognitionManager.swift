import Foundation
import Speech
import AVFoundation
import Combine

/// Manager for handling speech recognition using Apple's SFSpeechRecognizer
/// Processes speech on-device for privacy and speed
@MainActor
class SpeechRecognitionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isListening = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    @Published var isAuthorized = false
    
    // MARK: - Private Properties
    
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var processedLetterCount = 0  // Track how many letters we've already processed
    
    // Callback for when new text is recognized
    var onTextRecognized: ((String) -> Void)?
    
    // MARK: - Initialization
    
    init() {
        // Use British English locale to match the dictionary
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    self?.isAuthorized = true
                    self?.errorMessage = nil
                case .denied:
                    self?.isAuthorized = false
                    self?.errorMessage = "Speech recognition access denied. Please enable in Settings."
                case .restricted:
                    self?.isAuthorized = false
                    self?.errorMessage = "Speech recognition is restricted on this device."
                case .notDetermined:
                    self?.isAuthorized = false
                    self?.errorMessage = nil
                @unknown default:
                    self?.isAuthorized = false
                    self?.errorMessage = "Unknown authorization status."
                }
            }
        }
    }
    
    // MARK: - Recording Control
    
    func startListening(contextualStrings: [String] = []) {
        // Check authorization first
        guard isAuthorized else {
            requestAuthorization()
            return
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is not available."
            return
        }
        
        // Stop any existing recognition
        stopListening()
        
        do {
            // Reset state for new session
            transcribedText = ""
            processedLetterCount = 0
            
            try startRecording(contextualStrings: contextualStrings)
            isListening = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            isListening = false
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false
    }
    
    func toggleListening(contextualStrings: [String] = []) {
        if isListening {
            stopListening()
        } else {
            startListening(contextualStrings: contextualStrings)
        }
    }
    
    // MARK: - Private Methods
    
    private func startRecording(contextualStrings: [String]) throws {
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Apply contextual strings to improve accuracy
        if !contextualStrings.isEmpty {
            recognitionRequest?.contextualStrings = contextualStrings
        }
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        // Configure for real-time results
        recognitionRequest.shouldReportPartialResults = true
        
        // Use on-device recognition if available (iOS 13+)
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false // Set to true to force on-device only
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self, self.isListening else { return }
                
                if let result = result {
                    let text = result.bestTranscription.formattedString.uppercased()
                    self.transcribedText = text
                    
                    // Extract only letters for anagram input
                    let allLetters = String(text.filter { $0.isLetter })
                    
                    // Only process NEW letters (not already sent)
                    if allLetters.count > self.processedLetterCount {
                        let newLetters = String(allLetters.dropFirst(self.processedLetterCount))
                        self.processedLetterCount = allLetters.count
                        if !newLetters.isEmpty {
                            self.onTextRecognized?(newLetters)
                        }
                    }
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                }
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Validate the audio format - simulators may return invalid formats
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            throw NSError(
                domain: "SpeechRecognition",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Microphone not available. Please use a physical device for voice input."]
            )
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}

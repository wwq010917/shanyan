// SpeechManager.swift

import Foundation
import Speech
import AVFoundation
import UIKit

class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var insultCount:Int = getInsultCount()
    @Published var recognizedText: String = ""
    private var score:Double = 0.0
    private var previoussciprt:String = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) // For Simplified Chinese
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle authorization status
        }
    }
    
    func startRecording() {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            do {
                try startSpeechRecognition()
                //                NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.mediaServicesWereLostNotification, object: AVAudioSession.sharedInstance())
                NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            } catch {
                print("Error starting speech recognition: \(error)")
            }
        }
    }
    
    
    
    func stopRecording() {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)
            
            NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            
        }
    }
    @objc func handleAudioSessionInterruption(notification: Notification) {
        print("interrupt")
    }
    
    
    private func startSpeechRecognition() throws {
        // Cancel the previous task if it's running
        recognitionTask?.cancel()
        recognitionTask = nil
        
        
        let avaudioSession = AVAudioSession.sharedInstance()
        try avaudioSession.setCategory(.playAndRecord, mode: .voiceChat, options: .mixWithOthers)
        try avaudioSession.setActive(true, options: .notifyOthersOnDeactivation)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            self?.processRecognitionResult(result, error: error)
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    private func processRecognitionResult(_ result: SFSpeechRecognitionResult?, error: Error?) {
        guard let result = result else {
            
            return
        }
        DispatchQueue.main.async {
            let message = result.bestTranscription.formattedString
            let apiKey = "AIzaSyBmHlTTx9DCJzATUpxJTST9_mAMyggFqmg"
            if message.count >= 8 {
                print("Transcript length exceeds 5 characters.")
                var text:String
                let orginal = message
                text = message
                analyzeComment(withText: text, apiKey: apiKey) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let toxicityScore):
                            print(text)
                            print("Toxicity score: \(toxicityScore)")
                            if(toxicityScore > 0.75){
                                let currentCount = getInsultCount()
                                saveInsultCount(currentCount + 1)
                                saveBadSentence(text)
                                self.insultCount = currentCount + 1
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                        
                    }
                }
                self.stopRecording()
                self.startRecording()
                
            }
        }
    }
}

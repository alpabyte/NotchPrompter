//
//  AudioMonitor.swift
//  notch-prompter
//
//  Created by Jakub Pomykała on 07/12/2025.
//


import AVFoundation
import SwiftUI
import Combine
import Accelerate

final class AudioMonitor: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var inputNode: AVAudioInputNode?

    @Published var rmsLevel: Float = 0

    private var isRunning = false


    init() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
    }

    func startMonitoring() {
        guard !isRunning else { return }
        isRunning = true
        guard let inputNode else {
            isRunning = false
            return
        }

        let format = inputNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            isRunning = false
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 512, format: format) { [weak self] buffer, _ in
            guard let self else { return }
            let level = self.rms(buffer: buffer)
            DispatchQueue.main.async {
                self.rmsLevel = AudioLevel.smooth(previous: self.rmsLevel, sample: level)
            }
        }

        do {
            try audioEngine.start()
        } catch {
            inputNode.removeTap(onBus: 0)
            isRunning = false
            print("Error starting audio engine: \(error)")
        }
    }

    func stopMonitoring() {
        guard isRunning else { return }
        inputNode?.removeTap(onBus: 0)
        audioEngine.stop()
        isRunning = false
        DispatchQueue.main.async { [weak self] in self?.rmsLevel = 0 }
    }

    private func rms(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frameLength = vDSP_Length(buffer.frameLength)
        guard frameLength > 0 else { return 0 }

        var rmsValue: Float = 0
        vDSP_rmsqv(channelData, 1, &rmsValue, frameLength)
        return rmsValue
    }
}

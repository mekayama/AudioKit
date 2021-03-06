//
//  DrumSynths.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Kick Drum Synthesizer Instrument
open class AKSynthKick: AKMIDIInstrument {

    var generator: AKOperationGenerator
    var filter: AKMoogLadder

    /// Create the synth kick voice
    ///
    /// - Parameter midiInputName: Name of the instrument's MIDI input.
    @objc public override init(midiInputName: String? = nil) {

        generator = AKOperationGenerator { _ in
            let frequency = AKOperation.lineSegment(trigger: AKOperation.trigger, start: 120, end: 40, duration: 0.03)
            let volumeSlide = AKOperation.lineSegment(trigger: AKOperation.trigger, start: 1, end: 0, duration: 0.3)
            return AKOperation.sineWave(frequency: frequency, amplitude: volumeSlide)
        }

        filter = AKMoogLadder(generator)
        filter.cutoffFrequency = 666
        filter.resonance = 0.00

        super.init(midiInputName: midiInputName)
        avAudioUnit = filter.avAudioUnit
        generator.start()
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        filter.cutoffFrequency = (Double(velocity) / 127.0 * 366.0) + 300.0
        filter.resonance = 1.0 - Double(velocity) / 127.0
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    @objc open override func stop(noteNumber: MIDINoteNumber) {
        // Unneeded
    }
}

/// Snare Drum Synthesizer Instrument
open class AKSynthSnare: AKMIDIInstrument {

    var generator: AKOperationGenerator
    var filter: AKMoogLadder
    var duration = 0.143

    /// Create the synth snare voice
    @objc public init(duration: Double = 0.143, resonance: Double = 0.9) {
        self.duration = duration
        self.resonance = resonance

        generator = AKOperationGenerator { _ in
            let volSlide = AKOperation.lineSegment(
                trigger: AKOperation.trigger,
                start: 1,
                end: 0,
                duration: duration)
            return AKOperation.whiteNoise(amplitude: volSlide)
        }

        filter = AKMoogLadder(generator)
        filter.cutoffFrequency = 1_666

        super.init()
        avAudioUnit = filter.avAudioUnit
        generator.start()
    }

    internal var cutoff: Double = 1_666 {
        didSet {
            filter.cutoffFrequency = cutoff
        }
    }
    internal var resonance: Double = 0.3 {
        didSet {
            filter.resonance = resonance
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        cutoff = (Double(velocity) / 127.0 * 1_600.0) + 300.0
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    @objc open override func stop(noteNumber: MIDINoteNumber) {
        // Unneeded
    }
}

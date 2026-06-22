// Based on example at https://github.com/genedelisa/MIDIPlayer/blob/master/MIDIPlayer/ViewController.swift

import AVFoundation

@objc(MidiPlayback)
class MidiPlayback: NSObject {
    
    var midiPlayer: AVMIDIPlayer?
    var soundBankURL: URL?
    var fileURL: URL?
    var midiData: Data?

    // Resolve an input string to a usable URL. Accepts a file:// URL, an absolute
    // path, or a bare resource name (e.g. "ode_to_joy.mid") which is looked up in
    // the app's main bundle — that last form is how the host passes bundled
    // .mid / .sf2 files.
    private func resolveURL(_ input: String, defaultExt: String) -> URL? {
        if input.hasPrefix("file:") {
            return URL(string: input)
        }
        if input.hasPrefix("/") {
            return URL(fileURLWithPath: input)
        }
        let ns = input as NSString
        let ext = ns.pathExtension.isEmpty ? defaultExt : ns.pathExtension
        let name = ns.deletingPathExtension
        return Bundle.main.url(forResource: name, withExtension: ext)
    }

    @objc(setPlaybackFile:)
    func setPlaybackFile(_ midiFileURL: NSString) {
        self.fileURL = resolveURL(midiFileURL as String, defaultExt: "mid")
        self.midiData = nil
        guard let fileURL = self.fileURL else {
            print("MidiPlayback: could not resolve MIDI file: \(midiFileURL)")
            self.midiPlayer = nil
            return
        }
        do {
            self.midiPlayer = try AVMIDIPlayer(contentsOf: fileURL, soundBankURL: self.soundBankURL)
            self.midiPlayer?.prepareToPlay()
        } catch let error {
            print("MidiPlayback setPlaybackFile error: \(error.localizedDescription)")
            self.midiPlayer = nil
        }
    }

    @objc(setPlaybackData:)
    func setPlaybackData(_ midiData: NSData) {
        self.midiData = midiData as Data
        self.fileURL = nil
        do {
            try self.midiPlayer = AVMIDIPlayer(data: self.midiData!, soundBankURL: self.soundBankURL)
        } catch let error {
            print(error.localizedDescription)
        }

        self.midiPlayer?.prepareToPlay()
    }

    @objc(setSoundBank:)
    func setSoundBank(_ soundBankURL: NSString) {
        self.soundBankURL = resolveURL(soundBankURL as String, defaultExt: "sf2")
        // Re-create the player so the new bank applies to the loaded file/data.
        if let fileURL = self.fileURL {
            do {
                self.midiPlayer = try AVMIDIPlayer(contentsOf: fileURL, soundBankURL: self.soundBankURL)
                self.midiPlayer?.prepareToPlay()
            } catch let error {
                print("MidiPlayback setSoundBank error: \(error.localizedDescription)")
            }
        } else if let data = self.midiData {
            do {
                self.midiPlayer = try AVMIDIPlayer(data: data, soundBankURL: self.soundBankURL)
                self.midiPlayer?.prepareToPlay()
            } catch let error {
                print("MidiPlayback setSoundBank error: \(error.localizedDescription)")
            }
        }
    }

    @objc(play)
    func play() {
        self.midiPlayer?.play()
    }

    @objc(reset)
    func reset() {
        self.midiPlayer?.currentPosition = 0
    }

    @objc(stop)
    func stop() {
        self.midiPlayer?.stop()
    }

    @objc
    func isPlaying() -> Bool {
        if self.midiPlayer != nil {
            return self.midiPlayer!.isPlaying
        }
        else {
            return false
        }
    }
}

import AVFoundation
import Foundation

/// Named game sound effects (calm, short SFX).
enum GameSound: String, CaseIterable, Equatable {
    case place
    case remove
    case win

    /// Bundled file name under `Resources/Sounds/` (no extension).
    var resourceName: String { rawValue }
}

protocol SoundPlaying: AnyObject {
    func play(_ sound: GameSound)
}

/// Silent stand-in for tests and previews.
final class NoOpSoundService: SoundPlaying {
    func play(_ sound: GameSound) {}
}

/// Plays calm SFX for place / remove / win, respecting `SettingsStore.soundEnabled`
/// and the device silent switch via `.ambient` session category (P4.5).
@Observable
final class SoundService: SoundPlaying {
    private let settings: SettingsStore
    private let bundle: Bundle
    private var players: [GameSound: AVAudioPlayer] = [:]
    private var sessionConfigured = false

    init(settings: SettingsStore, bundle: Bundle = .main) {
        self.settings = settings
        self.bundle = bundle
        preloadPlayers()
    }

    func play(_ sound: GameSound) {
        guard settings.soundEnabled else { return }
        configureSessionIfNeeded()

        guard let player = players[sound] else { return }
        player.currentTime = 0
        player.play()
    }

    private func preloadPlayers() {
        for sound in GameSound.allCases {
            guard let url = audioURL(for: sound) else { continue }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = 0.55
                players[sound] = player
            } catch {
                // Missing or invalid assets fail silently (FR-5).
            }
        }
    }

    private func audioURL(for sound: GameSound) -> URL? {
        let name = sound.resourceName
        if let url = bundle.url(forResource: name, withExtension: "wav", subdirectory: "Sounds") {
            return url
        }
        return bundle.url(forResource: name, withExtension: "wav")
    }

    private func configureSessionIfNeeded() {
        guard !sessionConfigured else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            // Ambient: honors silent switch and mixes with other apps.
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
            sessionConfigured = true
        } catch {
            // Proceed without crashing; playback may be a no-op.
        }
    }
}

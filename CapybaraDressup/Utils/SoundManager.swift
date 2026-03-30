import AVFoundation

final class SoundManager {
    static let shared = SoundManager()
    private init() {
        configureAudioSession()
    }

    enum Sound: String {
        case purr
        case click
        case bark
        case chatter
    }

    private var players: [Sound: AVAudioPlayer] = [:]

    func play(_ sound: Sound) {
        // 이미 로드된 플레이어가 있으면 재사용
        if let player = players[sound] {
            player.currentTime = 0
            player.play()
            return
        }

        // 효과음 파일 로드 시도
        guard let url = Bundle.main.url(
            forResource: sound.rawValue,
            withExtension: "wav",
            subdirectory: "Sounds"
        ) else {
            // 파일이 없으면 시스템 사운드로 폴백
            playSystemFallback(sound)
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.5
            player.prepareToPlay()
            player.play()
            players[sound] = player
        } catch {
            playSystemFallback(sound)
        }
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            .ambient,
            mode: .default,
            options: [.mixWithOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// 효과음 파일이 없을 때 시스템 사운드로 대체
    private func playSystemFallback(_ sound: Sound) {
        let systemSoundID: SystemSoundID
        switch sound {
        case .purr: systemSoundID = 1004
        case .click: systemSoundID = 1104
        case .bark: systemSoundID = 1005
        case .chatter: systemSoundID = 1006
        }
        AudioServicesPlaySystemSound(systemSoundID)
    }
}

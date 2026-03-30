import Foundation

enum ExpressionState: String, CaseIterable {
    case idle
    case happy       // 쓰다듬기
    case eating      // 먹이
    case excited     // 놀기/점프
    case sleepy      // 롱프레스
    case surprised   // 갑작스런 탭
    case bathing     // 물웅덩이
    case irritated   // 과도한 터치 / 배고픔

    /// 눈 개방도 (0.0 = 완전 감김, 1.0 = 최대 크기)
    var eyeOpenness: CGFloat {
        switch self {
        case .idle:       return 0.7
        case .happy:      return 0.3
        case .eating:     return 0.7
        case .excited:    return 1.0
        case .sleepy:     return 0.15
        case .surprised:  return 1.0
        case .bathing:    return 0.3
        case .irritated:  return 0.5
        }
    }

    /// 귀 각도 (-1.0 뒤로 눕힘, 0 자연, 0.5 옆으로 벌어짐, 1.0 위로 세움)
    var earAngle: CGFloat {
        switch self {
        case .idle:       return 0.0
        case .happy:      return 0.5
        case .eating:     return 0.0
        case .excited:    return 1.0
        case .sleepy:     return -0.5
        case .surprised:  return 0.7
        case .bathing:    return 0.5
        case .irritated:  return -1.0
        }
    }

    /// 입 모양 (0.0 닫힘, 0.3 미소, 0.6 벌림, 1.0 크게 벌림)
    var mouthOpenness: CGFloat {
        switch self {
        case .idle:       return 0.0
        case .happy:      return 0.3
        case .eating:     return 0.6
        case .excited:    return 0.6
        case .sleepy:     return 0.0
        case .surprised:  return 0.8
        case .bathing:    return 0.2
        case .irritated:  return 0.4
        }
    }

    /// 입이 미소 형태인지
    var isSmiling: Bool {
        switch self {
        case .happy, .bathing: return true
        default: return false
        }
    }
}

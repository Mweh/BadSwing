import Foundation

enum SwingResult: Equatable {
    case good
    case tooSlow
    case noExtension
    case noSwing

    var displayMessage: String {
        switch self {
        case .good:         return "Great swing! 🏸"
        case .tooSlow:      return "Swing faster!"
        case .noExtension:  return "Extend your arm more"
        case .noSwing:      return "No swing detected"
        }
    }
}

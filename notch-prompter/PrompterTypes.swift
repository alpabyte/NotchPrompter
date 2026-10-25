import SwiftUI

// MARK: - Text alignment

enum PrompterTextAlignment: String, CaseIterable {
    case left
    case center
    case right

    var displayName: LocalizedStringKey {
        switch self {
        case .left: return "Left"
        case .center: return "Center"
        case .right: return "Right"
        }
    }

    var icon: String {
        switch self {
        case .left: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .right: return "text.alignright"
        }
    }

    var swiftUIAlignment: TextAlignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
}

extension Font.Design {
    var displayLocalizedName: LocalizedStringKey {
        LocalizedStringKey(displayName)
    }
}

import SwiftUI

/// Fold Book - Origami Log's own palette: distinct from every sibling app in the portfolio.
enum FBTheme {
    static let backdrop = Color(red: 0.973, green: 0.961, blue: 0.929)
    static let card = Color.white

    static let ink = Color(red: 0.18, green: 0.129, blue: 0.098)
    static let inkFaded = Color(red: 0.18, green: 0.129, blue: 0.098).opacity(0.56)

    static let accent = Color(red: 0.784, green: 0.302, blue: 0.243)
    static let accentDeep = Color(red: 0.7040000000000001, green: 0.22199999999999998, blue: 0.16299999999999998)
    static let accent2 = Color(red: 0.925, green: 0.663, blue: 0.243)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct FBDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(FBDismissKeyboardOnTap())
    }
}

enum FBHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

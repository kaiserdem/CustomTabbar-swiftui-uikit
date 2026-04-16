import SwiftUI

/// Має збігатися з `tabBarView.heightAnchor` у `CustomTabController`.
enum TabScreenMetrics {
    static let customTabBarHeight: CGFloat = 72
}

/// Фон і навбар задає **сам екран** (`background`); заповнення від статус-бару до низу девайсу, включно з-під кастомного таббару.
struct TabScreenChrome: ViewModifier {
    let background: Color

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.bottom, TabScreenMetrics.customTabBarHeight)
            .background {
                background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .all)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.colorScheme, .dark)
            .toolbarBackground(background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func tabScreenChrome(background: Color) -> some View {
        modifier(TabScreenChrome(background: background))
    }
}

import SwiftUI

/// Метрики кастомного таббару — узгоджені з `CustomTabController`.
enum TabScreenMetrics {
    static let tabBarViewHeight: CGFloat = 72
    /// Підйом таббару від нижнього краю екрану (той самий `constant` у Auto Layout).
    static let tabBarBottomOffset: CGFloat = 15
    /// Відступ контенту знизу: висота таббару + підйом, щоб не заходив під бар.
    static var contentBottomInset: CGFloat { tabBarViewHeight + tabBarBottomOffset }
}

/// Фон і навбар задає **сам екран** (`background`); заповнення від статус-бару до низу девайсу, включно з-під кастомного таббару.
struct TabScreenChrome: ViewModifier {
    let background: Color
    /// Якщо true — контент (особливо ScrollView) може заходити під tab bar (але НЕ під navigation bar).
    let allowScrollUnderTabBar: Bool

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .all)
            }
            // Дає можливість ScrollView “заїжджати” під bars, але зберігає докрутку,
            // щоб останній елемент можна було підняти вище таббару.
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: TabScreenMetrics.contentBottomInset)
            }
            .ignoresSafeArea(allowScrollUnderTabBar ? .container : [], edges: allowScrollUnderTabBar ? [.bottom] : [])
            .environment(\.colorScheme, .dark)
            .toolbarBackground(background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func tabScreenChrome(background: Color, allowScrollUnderTabBar: Bool = false) -> some View {
        modifier(TabScreenChrome(background: background, allowScrollUnderTabBar: allowScrollUnderTabBar))
    }
}

import SwiftUI


enum TabScreenMetrics {
    static let tabBarViewHeight: CGFloat = 72
    
    static let tabBarBottomOffset: CGFloat = 15
    
    static var contentBottomInset: CGFloat { tabBarViewHeight + tabBarBottomOffset }
}


struct TabScreenChrome: ViewModifier {
    let background: Color
    
    let allowScrollUnderTabBar: Bool

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .all)
            }
            
            
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

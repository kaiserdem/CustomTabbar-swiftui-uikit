import SwiftUI

enum RouteViewFactory {
    /// Повертає SwiftUI-екран без `AnyView`. `TabRouter` інжектиться зовні через `.environmentObject`.
    @ViewBuilder
    static func makeView(for screen: ScreenRoute) -> some View {
        switch screen.id {
        case "home.root":
            HomeRootView()
        case "home.details":
            HomeDetailsView()

        case "browse.root":
            BrowseRootView()
        case "browse.details":
            BrowseDetailsView()

        case "create.root":
            CreateRootView()

        case "notifications.root":
            NotificationsRootView()
        case "notifications.details":
            NotificationsDetailsView()

        case "profile.root":
            ProfileRootView()
        case "profile.settings":
            ProfileSettingsView()

        default:
            VStack(spacing: 12) {
                Text("Unknown screen")
                    .font(.title3).bold()
                Text(screen.id)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .tabScreenChrome(background: Color.black)
        }
    }
}

import SwiftUI

enum RouteViewFactory {
    static func makeView(for screen: ScreenRoute, router: TabRouter) -> AnyView {
        // В’юхи лишаються SwiftUI. Тут лише мапінг `screen.id -> View`.
        switch screen.id {
        case "home.root":
            return AnyView(HomeRootView().environmentObject(router))
        case "home.details":
            return AnyView(HomeDetailsView().environmentObject(router))

        case "browse.root":
            return AnyView(BrowseRootView().environmentObject(router))
        case "browse.details":
            return AnyView(BrowseDetailsView().environmentObject(router))

        case "create.root":
            return AnyView(CreateRootView().environmentObject(router))

        case "notifications.root":
            return AnyView(NotificationsRootView().environmentObject(router))
        case "notifications.details":
            return AnyView(NotificationsDetailsView().environmentObject(router))

        case "profile.root":
            return AnyView(ProfileRootView().environmentObject(router))
        case "profile.settings":
            return AnyView(ProfileSettingsView().environmentObject(router))

        default:
            return AnyView(
                VStack(spacing: 12) {
                    Text("Unknown screen")
                        .font(.title3).bold()
                    Text(screen.id)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding()
                .tabScreenChrome(background: Color.black)
            )
        }
    }
}

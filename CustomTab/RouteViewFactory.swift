import SwiftUI

enum RouteViewFactory {
    static func makeView(for route: AppRoute, router: TabRouter) -> AnyView {
        switch route {
        case .homeRoot:
            return AnyView(HomeRootView().environmentObject(router))
        case .homeDetails:
            return AnyView(HomeDetailsView().environmentObject(router))

        case .browseRoot:
            return AnyView(BrowseRootView().environmentObject(router))
        case .browseDetails:
            return AnyView(BrowseDetailsView().environmentObject(router))

        case .createRoot:
            return AnyView(CreateRootView().environmentObject(router))

        case .notificationsRoot:
            return AnyView(NotificationsRootView().environmentObject(router))
        case .notificationsDetails:
            return AnyView(NotificationsDetailsView().environmentObject(router))

        case .profileRoot:
            return AnyView(ProfileRootView().environmentObject(router))
        case .profileSettings:
            return AnyView(ProfileSettingsView().environmentObject(router))
        }
    }
}


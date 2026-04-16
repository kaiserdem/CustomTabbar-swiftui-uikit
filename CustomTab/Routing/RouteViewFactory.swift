import SwiftUI

enum RouteViewFactory {
    static func makeView(for route: AppRoute, router: TabRouter) -> AnyView {
        let view: AnyView
        switch route {
        case .homeRoot:
            view = AnyView(HomeRootView().environmentObject(router))
        case .homeDetails:
            view = AnyView(HomeDetailsView().environmentObject(router))

        case .browseRoot:
            view = AnyView(BrowseRootView().environmentObject(router))
        case .browseDetails:
            view = AnyView(BrowseDetailsView().environmentObject(router))

        case .createRoot:
            view = AnyView(CreateRootView().environmentObject(router))

        case .notificationsRoot:
            view = AnyView(NotificationsRootView().environmentObject(router))
        case .notificationsDetails:
            view = AnyView(NotificationsDetailsView().environmentObject(router))

        case .profileRoot:
            view = AnyView(ProfileRootView().environmentObject(router))
        case .profileSettings:
            view = AnyView(ProfileSettingsView().environmentObject(router))
        }

        return view
    }
}

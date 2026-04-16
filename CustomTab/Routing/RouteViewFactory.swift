import SwiftUI
import UIKit

enum RouteViewFactory {
    /// Один колір для SwiftUI й UIKit (фон контролера, навбар, контейнер).
    static func uiScreenBackground(for route: AppRoute) -> UIColor {
        switch route {
        case .homeRoot, .homeDetails:
            return UIColor(red: 0.07, green: 0.10, blue: 0.24, alpha: 1)
        case .browseRoot, .browseDetails:
            return UIColor(red: 0.06, green: 0.16, blue: 0.12, alpha: 1)
        case .createRoot:
            return UIColor(red: 0.14, green: 0.07, blue: 0.20, alpha: 1)
        case .notificationsRoot, .notificationsDetails:
            return UIColor(red: 0.18, green: 0.10, blue: 0.06, alpha: 1)
        case .profileRoot, .profileSettings:
            return UIColor(red: 0.10, green: 0.09, blue: 0.22, alpha: 1)
        }
    }

    private static func screenBackground(for route: AppRoute) -> Color {
        Color(uiColor: uiScreenBackground(for: route))
    }

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

        return AnyView(
            ZStack {
                screenBackground(for: route).ignoresSafeArea()
                view
            }
            .environment(\.colorScheme, .dark)
        )
    }
}


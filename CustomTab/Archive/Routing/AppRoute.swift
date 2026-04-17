import Foundation

enum AppRoute: Hashable {
    case homeRoot
    case homeDetails

    case browseRoot
    case browseDetails

    case createRoot

    case notificationsRoot
    case notificationsDetails

    case profileRoot
    case profileSettings
}

extension AppRoute {
    var tab: TabIdentifier {
        switch self {
        case .homeRoot, .homeDetails:
            return .home
        case .browseRoot, .browseDetails:
            return .browse
        case .createRoot:
            return .create
        case .notificationsRoot, .notificationsDetails:
            return .notifications
        case .profileRoot, .profileSettings:
            return .profile
        }
    }
}

extension TabIdentifier {
    var defaultRoute: AppRoute {
        switch self {
        case .home:
            return .homeRoot
        case .browse:
            return .browseRoot
        case .create:
            return .createRoot
        case .notifications:
            return .notificationsRoot
        case .profile:
            return .profileRoot
        }
    }
}


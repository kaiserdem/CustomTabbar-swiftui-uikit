import Foundation

/// Опис екрана для навігації.
/// Це **дані**, а не View: можна вільно будувати/міняти стеки без `AnyView`.
struct ScreenRoute: Hashable, Identifiable {
    let tab: TabIdentifier
    /// Стабільний ідентифікатор екрана (може бути рядком з модуля, напр. "home.root").
    let id: String
    /// Параметри екрана (опційно). Значення — Hashable, щоб `ScreenRoute` був Hashable.
    let params: [String: AnyHashable]

    init(tab: TabIdentifier, id: String, params: [String: AnyHashable] = [:]) {
        self.tab = tab
        self.id = id
        self.params = params
    }
}

extension TabIdentifier {
    var defaultScreen: ScreenRoute {
        switch self {
        case .home:
            return ScreenRoute(tab: .home, id: "home.root")
        case .browse:
            return ScreenRoute(tab: .browse, id: "browse.root")
        case .create:
            return ScreenRoute(tab: .create, id: "create.root")
        case .notifications:
            return ScreenRoute(tab: .notifications, id: "notifications.root")
        case .profile:
            return ScreenRoute(tab: .profile, id: "profile.root")
        }
    }
}

// Зручні конструктори для демо (не обов'язкові для архітектури).
extension ScreenRoute {
    static var homeRoot: ScreenRoute { .init(tab: .home, id: "home.root") }
    static var homeDetails: ScreenRoute { .init(tab: .home, id: "home.details") }

    static var browseRoot: ScreenRoute { .init(tab: .browse, id: "browse.root") }
    static var browseDetails: ScreenRoute { .init(tab: .browse, id: "browse.details") }

    static var createRoot: ScreenRoute { .init(tab: .create, id: "create.root") }

    static var notificationsRoot: ScreenRoute { .init(tab: .notifications, id: "notifications.root") }
    static var notificationsDetails: ScreenRoute { .init(tab: .notifications, id: "notifications.details") }

    static var profileRoot: ScreenRoute { .init(tab: .profile, id: "profile.root") }
    static var profileSettings: ScreenRoute { .init(tab: .profile, id: "profile.settings") }
}

//
//  ScreenRoute.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import Foundation



struct ScreenRoute: Hashable, Identifiable {
    let tab: TabIdentifier
    
    let id: String
    
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
        case .main:
            return ScreenRoute(tab: .main, id: "main.root")
        case .lobby:
            return ScreenRoute(tab: .lobby, id: "lobby.root")
        case .menu:
            return ScreenRoute(tab: .menu, id: "menu.root")
        case .bonuses:
            return ScreenRoute(tab: .bonuses, id: "bonuses.root")
        case .profile:
            return ScreenRoute(tab: .profile, id: "profile.root")
        }
    }
}


extension ScreenRoute {
    static var mainRoot: ScreenRoute { .init(tab: .main, id: "main.root") }
    static var mainDetails: ScreenRoute { .init(tab: .main, id: "main.details") }

    static var lobbyRoot: ScreenRoute { .init(tab: .lobby, id: "lobby.root") }
    static var lobbyDetails: ScreenRoute { .init(tab: .lobby, id: "lobby.details") }

    static var menuRoot: ScreenRoute { .init(tab: .menu, id: "menu.root") }

    static var bonusesRoot: ScreenRoute { .init(tab: .bonuses, id: "bonuses.root") }
    static var bonusesDetails: ScreenRoute { .init(tab: .bonuses, id: "bonuses.details") }

    static var profileRoot: ScreenRoute { .init(tab: .profile, id: "profile.root") }
    static var profileDetails: ScreenRoute { .init(tab: .profile, id: "profile.details") }
}

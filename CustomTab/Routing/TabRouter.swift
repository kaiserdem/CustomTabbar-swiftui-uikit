import Foundation
import Combine
import SwiftUI

@MainActor
final class TabRouter: ObservableObject {
    @Published private(set) var selectedTab: TabIdentifier

    private var routesByTab: [TabIdentifier: AppRoute]
    weak var navigator: TabNavigator?

    init(initialTab: TabIdentifier = .home) {
        self.selectedTab = initialTab
        self.routesByTab = Dictionary(uniqueKeysWithValues: TabIdentifier.allCases.map { ($0, $0.defaultRoute) })
    }

    func route(for tab: TabIdentifier) -> AppRoute {
        routesByTab[tab] ?? tab.defaultRoute
    }

    func selectTab(_ tab: TabIdentifier, to route: AppRoute? = nil, animated: Bool = true) {
        if let route {
            routesByTab[tab] = route
        }
        selectedTab = tab
        navigator?.selectTab(tab, to: routesByTab[tab] ?? tab.defaultRoute, animated: animated)
    }

    func setRoute(_ route: AppRoute, for tab: TabIdentifier) {
        routesByTab[tab] = route
    }

    func push(_ route: AppRoute, animated: Bool = true) {
        // Якщо маршрут належить іншій вкладці — перемикаємо вкладку й показуємо конкретний екран.
        if route.tab != selectedTab {
            selectTab(route.tab, to: route, animated: animated)
            return
        }
        navigator?.push(route, animated: animated)
    }
}

protocol TabNavigator: AnyObject {
    func selectTab(_ tab: TabIdentifier, to route: AppRoute, animated: Bool)
    func push(_ route: AppRoute, animated: Bool)
}


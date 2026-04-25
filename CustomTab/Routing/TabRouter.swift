//
//  TabRouter.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class TabRouter {
    private(set) var selectedTab: TabIdentifier

    private var stacksByTab: [TabIdentifier: [ScreenRoute]]
    weak var navigator: TabNavigator?

    var reservesTabBarSpace: Bool {
        stack(for: selectedTab).count <= 1
    }

    init(initialTab: TabIdentifier = .main) {
        self.selectedTab = initialTab
        self.stacksByTab = Dictionary(uniqueKeysWithValues: TabIdentifier.allCases.map { ($0, [$0.defaultScreen]) })
    }

    

    func stack(for tab: TabIdentifier) -> [ScreenRoute] {
        stacksByTab[tab] ?? [tab.defaultScreen]
    }

    func top(for tab: TabIdentifier) -> ScreenRoute {
        stack(for: tab).last ?? tab.defaultScreen
    }

    

    func selectTab(_ tab: TabIdentifier, animated: Bool = true) {
        selectedTab = tab
        navigator?.selectTab(tab, animated: animated)
    }

    func selectTab(_ tab: TabIdentifier, setStack stack: [ScreenRoute], animated: Bool = true) {
        setStack(stack, for: tab, animated: false)
        selectTab(tab, animated: animated)
    }

    func push(_ screen: ScreenRoute, animated: Bool = true) {
        if screen.tab != selectedTab {
            
            selectTab(screen.tab, setStack: [screen.tab.defaultScreen, screen], animated: animated)
            return
        }

        stacksByTab[selectedTab, default: [selectedTab.defaultScreen]].append(screen)
        navigator?.push(screen, on: selectedTab, animated: animated)
    }

    func pop(animated: Bool = true) {
        var stack = stacksByTab[selectedTab, default: [selectedTab.defaultScreen]]
        guard stack.count > 1 else { return }
        _ = stack.popLast()
        stacksByTab[selectedTab] = stack
        navigator?.pop(on: selectedTab, animated: animated)
    }

    func setStack(_ stack: [ScreenRoute], for tab: TabIdentifier, animated: Bool = true) {
        let normalized: [ScreenRoute]
        if stack.isEmpty {
            normalized = [tab.defaultScreen]
        } else {
            
            normalized = stack.map { ScreenRoute(tab: tab, id: $0.id, params: $0.params) }
        }

        stacksByTab[tab] = normalized
        navigator?.setStack(normalized, for: tab, animated: animated)
    }

    func replaceTop(with screen: ScreenRoute, animated: Bool = true) {
        let tab = screen.tab
        var stack = stacksByTab[tab, default: [tab.defaultScreen]]
        if stack.isEmpty {
            stack = [tab.defaultScreen]
        }
        _ = stack.popLast()
        stack.append(screen)
        setStack(stack, for: tab, animated: animated)
    }

    

    
    func syncStackFromNavigator(_ stack: [ScreenRoute], for tab: TabIdentifier) {
        
        let normalized = stack.isEmpty ? [tab.defaultScreen] : stack.map { ScreenRoute(tab: tab, id: $0.id, params: $0.params) }
        stacksByTab[tab] = normalized
    }
}

protocol TabNavigator: AnyObject {
    func selectTab(_ tab: TabIdentifier, animated: Bool)
    func setStack(_ stack: [ScreenRoute], for tab: TabIdentifier, animated: Bool)
    func push(_ screen: ScreenRoute, on tab: TabIdentifier, animated: Bool)
    func pop(on tab: TabIdentifier, animated: Bool)
}

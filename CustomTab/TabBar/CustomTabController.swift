//
//  CustomTabController.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI
import UIKit

final class CustomTabController: UIViewController, TabNavigator {
    private let router: TabRouter

    private let containerView = UIView()
    private let tabBarView: CustomTabBarView

    private var navControllers: [TabIdentifier: UINavigationController] = [:]
    private var currentTab: TabIdentifier
    private weak var currentNavController: UINavigationController?

    private var tabByNavController: [UINavigationController: TabIdentifier] = [:]

    init(router: TabRouter) {
        self.router = router
        self.currentTab = router.selectedTab

        let items: [CustomTabBarView.Item] = [
            .init(tab: .main, systemImage: "house", isCenter: false, title: "Головна"),
            .init(tab: .lobby, systemImage: "play", isCenter: false, title: "Лоббі"),
            .init(tab: .menu, systemImage: "list.bullet", isCenter: true, title: "Меню"),
            .init(tab: .bonuses, systemImage: "gift", isCenter: false, title: "Бонуси"),
            .init(tab: .profile, systemImage: "person", isCenter: false, title: "Профіль")
        ]

        self.tabBarView = CustomTabBarView(
            items: items,
            selectedTab: router.selectedTab,
            onSelect: { [weak router] tab in
                router?.selectTab(tab, animated: true)
            }
        )

        super.init(nibName: nil, bundle: nil)
        router.navigator = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationControllers()

        
        for tab in TabIdentifier.allCases {
            setStack(router.stack(for: tab), for: tab, animated: false)
        }

        selectTab(currentTab, animated: false)
    }

    private func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
        view.addSubview(tabBarView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -TabScreenMetrics.tabBarBottomOffset),
            tabBarView.heightAnchor.constraint(equalToConstant: TabScreenMetrics.tabBarViewHeight)
        ])
    }

    private func setupNavigationControllers() {
        for tab in TabIdentifier.allCases {
            let nav = UINavigationController()
            nav.delegate = self
            nav.view.backgroundColor = .clear
            nav.navigationBar.isTranslucent = true
            navControllers[tab] = nav
            tabByNavController[nav] = tab
        }
    }

    private func makeHostingController(for screen: ScreenRoute) -> UIViewController {
        let root = ScreenHostView(screen: screen, router: router)
        let vc = ScreenHostingController(rootView: root)
        vc.view.backgroundColor = .clear
        return vc
    }

    

    func selectTab(_ tab: TabIdentifier, animated: Bool) {
        currentTab = tab
        tabBarView.setSelectedTab(tab, animated: animated)

        guard let nav = navControllers[tab] else { return }

        if currentNavController !== nav {
            switchToNavController(nav, animated: animated)
        } else {
            syncChromeBackground(with: nav)
        }
        applyTabBarVisibility(for: nav, animated: animated)
    }

    func setStack(_ stack: [ScreenRoute], for tab: TabIdentifier, animated: Bool) {
        guard let nav = navControllers[tab] else { return }
        let vcs = stack.map(makeHostingController(for:))
        nav.setViewControllers(vcs, animated: animated)

        if tab == currentTab {
            syncChromeBackground(with: nav)
        }
    }

    func push(_ screen: ScreenRoute, on tab: TabIdentifier, animated: Bool) {
        guard let nav = navControllers[tab] else { return }
        let vc = makeHostingController(for: screen)
        nav.pushViewController(vc, animated: animated)

        if tab == currentTab {
            syncChromeBackground(with: nav)
        }
    }

    func pop(on tab: TabIdentifier, animated: Bool) {
        guard let nav = navControllers[tab] else { return }
        nav.popViewController(animated: animated)

        if tab == currentTab {
            syncChromeBackground(with: nav)
        }
    }

    private func switchToNavController(_ nav: UINavigationController, animated: Bool) {
        let fromNav = currentNavController
        currentNavController = nav

        if let fromNav {
            fromNav.willMove(toParent: nil)
            fromNav.view.removeFromSuperview()
            fromNav.removeFromParent()
        }

        addChild(nav)
        nav.view.frame = containerView.bounds
        nav.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(nav.view)
        nav.didMove(toParent: self)
        syncChromeBackground(with: nav)

        if animated, let _ = fromNav {
            nav.view.alpha = 0
            UIView.animate(withDuration: 0.2) { nav.view.alpha = 1 }
        }
    }

    private func syncChromeBackground(with nav: UINavigationController) {
        containerView.backgroundColor = .clear
        view.backgroundColor = .clear
        nav.view.backgroundColor = .clear
    }

    private func applyTabBarVisibility(for nav: UINavigationController, animated: Bool) {
        let hide = nav.viewControllers.count > 1
        tabBarView.isUserInteractionEnabled = !hide
        let applyAlpha = {
            self.tabBarView.alpha = hide ? 0 : 1
        }
        if animated, let coordinator = nav.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in applyAlpha() })
        } else if animated {
            UIView.animate(withDuration: 0.25, animations: applyAlpha)
        } else {
            applyAlpha()
        }
    }
}

private final class ScreenHostingController: UIHostingController<ScreenHostView> {
    override init(rootView: ScreenHostView) {
        super.init(rootView: rootView)
        edgesForExtendedLayout = [.top, .bottom, .left, .right]
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyScreenChrome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyScreenChrome()
    }

    private func applyScreenChrome() {
        view.backgroundColor = .clear
        guard let nav = navigationController else { return }
        nav.view.backgroundColor = .clear
        nav.navigationBar.isTranslucent = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.compactAppearance = appearance
        nav.navigationBar.compactScrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = .white
    }
}


private struct ScreenHostView: View {
    let screen: ScreenRoute
    let router: TabRouter

    var body: some View {
        RouteViewFactory
            .makeView(for: screen)
            .environmentObject(router)
    }
}

extension CustomTabController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard navigationController === currentNavController else { return }
        applyTabBarVisibility(for: navigationController, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let tab = tabByNavController[navigationController] else { return }

        
        let stack: [ScreenRoute] = navigationController.viewControllers.compactMap { vc in
            (vc as? ScreenHostingController)?.rootView.screen
        }

        router.syncStackFromNavigator(stack, for: tab)
        syncChromeBackground(with: navigationController)
        if navigationController === currentNavController {
            applyTabBarVisibility(for: navigationController, animated: false)
        }
    }
}

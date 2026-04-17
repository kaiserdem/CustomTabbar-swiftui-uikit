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
            .init(tab: .home, systemImage: "house", isCenter: false, title: "Головна"),
            .init(tab: .browse, systemImage: "play", isCenter: false, title: "Лобі"),
            .init(tab: .create, systemImage: "list.bullet", isCenter: true, title: "Меню"),
            .init(tab: .notifications, systemImage: "gift", isCenter: false, title: "Бонуси"),
            .init(tab: .profile, systemImage: "person", isCenter: false, title: "Панель")
        ]

        self.tabBarView = CustomTabBarView(
            items: items,
            selectedTab: router.selectedTab,
            onSelect: { [weak router] tab in
                guard let router else { return }
                router.selectTab(tab, to: router.route(for: tab), animated: true)
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
        selectTab(currentTab, to: router.route(for: currentTab), animated: false)
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
            // До низу екрану: SwiftUI-фон екрану може заходити під напівпрозорий таббар.
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Трохи вище за нижній край екрану — див. `TabScreenMetrics.tabBarBottomOffset`.
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -TabScreenMetrics.tabBarBottomOffset),
            tabBarView.heightAnchor.constraint(equalToConstant: TabScreenMetrics.tabBarViewHeight)
        ])
    }

    private func setupNavigationControllers() {
        for tab in TabIdentifier.allCases {
            let rootRoute = router.route(for: tab)
            let nav = UINavigationController(rootViewController: makeHostingController(for: rootRoute))
            nav.delegate = self
            nav.view.backgroundColor = .clear
            nav.navigationBar.isTranslucent = true
            navControllers[tab] = nav
            tabByNavController[nav] = tab
        }
    }

    private func makeHostingController(for route: AppRoute) -> UIViewController {
        // `TabRouter` передаємо в SwiftUI як `@EnvironmentObject`.
        let root = RouteViewFactory.makeView(for: route, router: router)
        let vc = RouteHostingController(route: route, rootView: root)
        vc.view.backgroundColor = .clear
        return vc
    }

    // MARK: - TabNavigator

    func selectTab(_ tab: TabIdentifier, to route: AppRoute, animated: Bool) {
        currentTab = tab
        tabBarView.setSelectedTab(tab, animated: animated)

        guard let nav = navControllers[tab] else { return }

        // Переконуємось, що вкладка показує конкретний екран.
        if (nav.topViewController as? RouteHostingController)?.route != route {
            nav.setViewControllers([makeHostingController(for: route)], animated: false)
        }

        // Міняємо контейнерний child-контролер.
        if currentNavController !== nav {
            switchToNavController(nav, animated: animated)
        } else {
            syncChromeBackground(with: nav)
        }
    }

    func push(_ route: AppRoute, animated: Bool) {
        // Переходи між вкладками робить TabRouter.
        guard let nav = navControllers[currentTab] else { return }

        let vc = makeHostingController(for: route)
        nav.pushViewController(vc, animated: animated)
    }

    private func switchToNavController(_ nav: UINavigationController, animated: Bool) {
        let fromNav = currentNavController
        currentNavController = nav

        // Прибираємо попередній показаний контролер.
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

        if animated, let fromNav {
            // Невелика fade-анімація при перемиканні.
            nav.view.alpha = 0
            UIView.animate(withDuration: 0.2, animations: { nav.view.alpha = 1 })
        }
    }
}

private final class RouteHostingController: UIHostingController<AnyView> {
    let route: AppRoute

    init(route: AppRoute, rootView: AnyView) {
        self.route = route
        super.init(rootView: rootView)
        // Щоб SwiftUI міг малювати під системним навбаром і до країв екрану.
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
        // Колір екрану задає SwiftUI у в’ю; тут лише прозорий шар, щоб був виден повний фон.
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

extension CustomTabController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let tab = tabByNavController[navigationController] else { return }
        guard let hosting = viewController as? RouteHostingController else { return }
        router.setRoute(hosting.route, for: tab)
        syncChromeBackground(with: navigationController)
    }

    private func syncChromeBackground(with nav: UINavigationController) {
        containerView.backgroundColor = .clear
        view.backgroundColor = .clear
        nav.view.backgroundColor = .clear
    }
}


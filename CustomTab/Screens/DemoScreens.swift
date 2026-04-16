import SwiftUI

struct HomeRootView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Home Root")
                .font(.title2)
                .bold()

            Button("Push: Home Details") {
                router.push(.homeDetails, animated: true)
            }

            Button("Перемкнути на Profile і показати Settings") {
                router.selectTab(.profile, to: .profileSettings, animated: true)
            }
        }
        .padding()
    }
}

struct HomeDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Home Details")
                .font(.title2)
                .bold()

            Button("Показати Browse Details в іншій вкладці") {
                router.selectTab(.browse, to: .browseDetails, animated: true)
            }

            Button("Назад може бути стандартним pop у цій вкладці") {
                // Заглушка для UX; back буде з navigation bar.
            }
        }
        .padding()
    }
}

struct BrowseRootView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Browse Root")
                .font(.title2)
                .bold()

            Button("Push: Browse Details") {
                router.push(.browseDetails, animated: true)
            }

            Button("Перемкнути на Notifications і показати Details") {
                router.selectTab(.notifications, to: .notificationsDetails, animated: true)
            }
        }
        .padding()
    }
}

struct BrowseDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Browse Details")
                .font(.title2)
                .bold()

            Button("Перемкнути на Home і показати Details") {
                router.selectTab(.home, to: .homeDetails, animated: true)
            }
        }
        .padding()
    }
}

struct CreateRootView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Create")
                .font(.title2)
                .bold()

            Button("Перейти в Profile Settings") {
                router.selectTab(.profile, to: .profileSettings, animated: true)
            }

            Button("Push: Notifications Details") {
                router.push(.notificationsDetails, animated: true)
            }
        }
        .padding()
    }
}

struct NotificationsRootView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Notifications Root")
                .font(.title2)
                .bold()

            Button("Push: Notifications Details") {
                router.push(.notificationsDetails, animated: true)
            }

            Button("Перемкнути на Home Root") {
                router.selectTab(.home, to: .homeRoot, animated: true)
            }
        }
        .padding()
    }
}

struct NotificationsDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Notifications Details")
                .font(.title2)
                .bold()

            Button("Відкрити Browse Root (конкретний екран)") {
                router.selectTab(.browse, to: .browseRoot, animated: true)
            }
        }
        .padding()
    }
}

struct ProfileRootView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile Root")
                .font(.title2)
                .bold()

            Button("Перейти в Profile Settings (push) ") {
                router.push(.profileSettings, animated: true)
            }

            Button("Перемкнути на Home і показати Details") {
                router.selectTab(.home, to: .homeDetails, animated: true)
            }
        }
        .padding()
    }
}

struct ProfileSettingsView: View {
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile Settings")
                .font(.title2)
                .bold()

            Button("Показати Create вкладку") {
                router.selectTab(.create, to: .createRoot, animated: true)
            }
        }
        .padding()
    }
}


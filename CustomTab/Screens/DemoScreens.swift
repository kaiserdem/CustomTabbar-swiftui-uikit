import SwiftUI

struct HomeRootView: View {
    @EnvironmentObject private var router: TabRouter

    /// Колір цього екрану задаєш тут (і лише тут для цього в’ю).
    private let screenBackground = Color(red: 0.07, green: 0.10, blue: 0.24)

    var body: some View {
//        ZStack {
//            Color.red
//                .scaledToFill()
//                .ignoresSafeArea()
            
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
            .tabScreenChrome(background: .red)
     //   }
    }
}

struct HomeDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.09, green: 0.12, blue: 0.28)

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
        .tabScreenChrome(background: screenBackground)
    }
}

struct BrowseRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.06, green: 0.16, blue: 0.12)

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
        .tabScreenChrome(background: screenBackground)
    }
}

struct BrowseDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.05, green: 0.20, blue: 0.14)

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
        .tabScreenChrome(background: screenBackground)
    }
}

struct CreateRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.14, green: 0.07, blue: 0.20)

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
        .tabScreenChrome(background: screenBackground)
    }
}

struct NotificationsRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.18, green: 0.10, blue: 0.06)

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
        .tabScreenChrome(background: screenBackground)
    }
}

struct NotificationsDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.22, green: 0.12, blue: 0.07)

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
        .tabScreenChrome(background: screenBackground)
    }
}

struct ProfileRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.10, green: 0.09, blue: 0.22)

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
        .tabScreenChrome(background: screenBackground)
    }
}

struct ProfileSettingsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.08, green: 0.07, blue: 0.26)

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
        .tabScreenChrome(background: screenBackground)
    }
}

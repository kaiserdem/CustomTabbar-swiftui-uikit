import SwiftUI

struct HomeRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.07, green: 0.10, blue: 0.24)

    private struct BorderPreset: Identifiable {
        let id: String
        let background: Color
        let border: Color
        let animatedBorder: Color
    }

    private let presets: [BorderPreset] = [
        .init(id: "Gold", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.84, blue: 0.20)),
        .init(id: "Emerald", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.20, green: 0.95, blue: 0.62)),
        .init(id: "Ruby", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.25, blue: 0.35)),
        .init(id: "Sapphire", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.30, green: 0.62, blue: 1.00)),
        .init(id: "Amethyst", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.72, green: 0.35, blue: 1.00)),
        .init(id: "Neon Pink", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.24, blue: 0.78)),
        .init(id: "Cyan", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.20, green: 0.92, blue: 1.00)),
        .init(id: "Orange", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 1.00, green: 0.55, blue: 0.18)),
        .init(id: "Lime", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color(red: 0.74, green: 1.00, blue: 0.22)),
        .init(id: "Ice", background: Color.black.opacity(0.35), border: Color.white.opacity(0.12), animatedBorder: Color.white.opacity(0.95))
    ]

    @State private var selectedPresetIndex: Int = 0

    var body: some View {
        let preset = presets[max(0, min(selectedPresetIndex, presets.count - 1))]

        ScrollView {
            VStack(spacing: 14) {
                Text("Home Root")
                    .font(.title2)
                    .bold()

                AnimatedBorderView(
                    cornerRadius: 18,
                    backgroundColor: preset.background,
                    borderColor: preset.border,
                    borderWidth: 1,
                    animatedBorderColor: preset.animatedBorder,
                    animatedBorderWidth: 2.5,
                    glowRadius: 4,
                    duration: 3.25
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Shimmer buttons")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.85))

                            HStack(spacing: 12) {
                                ShimmerButton(
                                    title: "SPIN",
                                    width: nil,
                                    height: 54,
                                    borderColor: preset.animatedBorder,
                                    backgroundColor: LinearGradient(
                                        colors: [Color.black.opacity(0.85), Color.black.opacity(0.55)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    textColor: preset.animatedBorder,
                                    fontSize: 18
                                ) {
                                    router.selectTab(.browse, setStack: [.browseRoot], animated: true)
                                }

                                Button {
                                    router.selectTab(.notifications, setStack: [.notificationsRoot], animated: true)
                                } label: {
                                    Text("BONUS")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(Color.yellow)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 14)
                                }
                                .buttonStyle(
                                    ShimmerButtonStyle(
                                        borderColor: .yellow,
                                        backgroundColor: AnyShapeStyle(Color.black.opacity(0.75))
                                    )
                                )
                            }

                            Text("Приклад shimmerBorder на контейнері")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.65))

                            HStack {
                                Text("Jackpot")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("$ 12 450")
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(.yellow)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shimmerBorder(cornerRadius: 16)
                        }
                        .padding(.top, 2)

                        HStack(spacing: 10) {
                            Text("Casino Card")
                                .font(.headline)
                            Spacer()
                            Text(preset.id)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        Text("Обери колір анімованого бордеру — це швидко дає потрібний вайб.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.78))

                        HStack(spacing: 10) {
                            Button("Push: Home Details") {
                                router.push(.homeDetails, animated: true)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Profile Settings") {
                                router.selectTab(.profile, setStack: [.profileRoot, .profileSettings], animated: true)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Text("10 пресетів")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(Array(presets.enumerated()), id: \.offset) { idx, p in
                        Button {
                            selectedPresetIndex = idx
                        } label: {
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(p.animatedBorder)
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                    )

                                Text(p.id)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)

                                Spacer(minLength: 0)

                                if idx == selectedPresetIndex {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(idx == selectedPresetIndex ? 0.10 : 0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(idx == selectedPresetIndex ? 0.22 : 0.10), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .tabScreenChrome(background: screenBackground, allowScrollUnderTabBar: true)
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
                router.selectTab(.browse, setStack: [.browseRoot, .browseDetails], animated: true)
            }

            Button("Назад може бути стандартним pop у цій вкладці") {
                
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

            Button("Перемкнути на Бонуси і показати Деталі") {
                router.selectTab(.notifications, setStack: [.notificationsRoot, .notificationsDetails], animated: true)
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
                router.selectTab(.home, setStack: [.homeRoot, .homeDetails], animated: true)
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
                router.selectTab(.profile, setStack: [.profileRoot, .profileSettings], animated: true)
            }

            Button("Показати деталі бонусів") {
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
            Text("Бонуси")
                .font(.title2)
                .bold()

            Button("Показати деталі бонусів") {
                router.push(.notificationsDetails, animated: true)
            }

            Button("Перемкнути на Home Root") {
                router.selectTab(.home, setStack: [.homeRoot], animated: true)
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
            Text("Деталі бонусів")
                .font(.title2)
                .bold()

            Button("Відкрити Browse Root (конкретний екран)") {
                router.selectTab(.browse, setStack: [.browseRoot], animated: true)
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
                router.selectTab(.home, setStack: [.homeRoot, .homeDetails], animated: true)
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
                router.selectTab(.create, setStack: [.createRoot], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

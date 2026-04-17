//
//  HomeRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct HomeRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.07, green: 0.10, blue: 0.24)

    private let presets = HomeBorderPresets.all

    @State private var selectedPresetIndex: Int = 0

    var body: some View {
        let preset = presets[max(0, min(selectedPresetIndex, presets.count - 1))]

        ScrollView {
            VStack(spacing: 14) {
                Text("Головна")
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
                            Button("Деталі екрану") {
                                router.push(.homeDetails, animated: true)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Налаштування профілю") {
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

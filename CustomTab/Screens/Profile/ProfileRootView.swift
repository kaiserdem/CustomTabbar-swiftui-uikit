//
//  ProfileRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct ProfileRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.10, green: 0.09, blue: 0.22)

    var body: some View {
        VStack(spacing: 16) {
            Text("Профіль")
                .font(.title2)
                .bold()

            Button("Налаштування (push)") {
                router.push(.profileSettings, animated: true)
            }

            Button("Головна: показати деталі") {
                router.selectTab(.home, setStack: [.homeRoot, .homeDetails], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

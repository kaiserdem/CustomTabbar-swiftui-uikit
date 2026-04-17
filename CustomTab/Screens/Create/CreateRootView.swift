//
//  CreateRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct CreateRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.14, green: 0.07, blue: 0.20)

    var body: some View {
        VStack(spacing: 16) {
            Text("Меню")
                .font(.title2)
                .bold()

            Button("Налаштування профілю") {
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

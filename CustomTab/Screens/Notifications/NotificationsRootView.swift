//
//  NotificationsRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

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

            Button("Перейти на головну") {
                router.selectTab(.home, setStack: [.homeRoot], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

//
//  BonusesRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct BonusesRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.18, green: 0.10, blue: 0.06)

    var body: some View {
        VStack(spacing: 16) {
            Text("Бонуси")
                .font(.title2)
                .bold()

            Button("Деталі бонусів") {
                router.push(.bonusesDetails, animated: true)
            }

            Button("Перейти на головну") {
                router.selectTab(.main, setStack: [.mainRoot], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

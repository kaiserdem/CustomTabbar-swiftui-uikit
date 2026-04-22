//
//  MenuRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct MenuRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.14, green: 0.07, blue: 0.20)

    var body: some View {
        VStack(spacing: 16) {
            Text("Меню")
                .font(.title2)
                .bold()

            Button("Деталі профілю") {
                router.selectTab(.profile, setStack: [.profileRoot, .profileDetails], animated: true)
            }

            Button("Бонуси: деталі") {
                router.selectTab(.bonuses, setStack: [.bonusesRoot, .bonusesDetails], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

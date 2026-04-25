//
//  MenuRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct MenuRootView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.14, green: 0.07, blue: 0.20)

    var body: some View {
        VStack(spacing: 16) {
            Text("Menu")
                .font(.title2)
                .bold()

            Button("Profile details") {
                router.selectTab(.profile, setStack: [.profileRoot, .profileDetails], animated: true)
            }

            Button("Bonuses: details") {
                router.selectTab(.bonuses, setStack: [.bonusesRoot, .bonusesDetails], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

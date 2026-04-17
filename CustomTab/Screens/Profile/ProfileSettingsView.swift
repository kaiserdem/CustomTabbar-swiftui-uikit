//
//  ProfileSettingsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.08, green: 0.07, blue: 0.26)

    var body: some View {
        VStack(spacing: 16) {
            Text("Налаштування")
                .font(.title2)
                .bold()

            Button("Відкрити меню") {
                router.selectTab(.create, setStack: [.createRoot], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

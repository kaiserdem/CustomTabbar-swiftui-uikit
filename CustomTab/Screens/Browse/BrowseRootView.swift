//
//  BrowseRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct BrowseRootView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.06, green: 0.16, blue: 0.12)

    var body: some View {
        VStack(spacing: 16) {
            Text("Лоббі")
                .font(.title2)
                .bold()

            Button("Деталі лоббі") {
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

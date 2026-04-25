//
//  MainDetailsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct MainDetailsView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.09, green: 0.12, blue: 0.28)

    var body: some View {
        VStack(spacing: 16) {
            Text("Details")
                .font(.title2)
                .bold()

            Button("Lobby: details in another tab") {
                router.selectTab(.lobby, setStack: [.lobbyRoot, .lobbyDetails], animated: true)
            }

            Button("Back") {
                router.pop(animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

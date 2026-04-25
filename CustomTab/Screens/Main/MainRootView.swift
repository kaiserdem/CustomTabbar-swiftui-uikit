//
//  MainRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct MainRootView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.07, green: 0.10, blue: 0.24)

    var body: some View {
        VStack(spacing: 16) {
            Text("Main")
                .font(.title2)
                .bold()

            Button("Screen details") {
                router.push(.mainDetails, animated: true)
            }
            .buttonStyle(.bordered)

            Button("Profile details") {
                router.selectTab(.profile, setStack: [.profileRoot, .profileDetails], animated: true)
            }
            .buttonStyle(.bordered)
            
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

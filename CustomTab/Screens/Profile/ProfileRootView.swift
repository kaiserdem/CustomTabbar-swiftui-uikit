//
//  ProfileRootView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct ProfileRootView: View {
    @Environment(TabRouter.self) private var router

    private let screenBackground = Color(red: 0.10, green: 0.09, blue: 0.22)

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile")
                .font(.title2)
                .bold()

            Button("Profile details") {
                router.push(.profileDetails, animated: true)
            }

            Button("Main: show details") {
                router.selectTab(.main, setStack: [.mainRoot, .mainDetails], animated: true)
            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

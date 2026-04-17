//
//  HomeDetailsView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

import SwiftUI

struct HomeDetailsView: View {
    @EnvironmentObject private var router: TabRouter

    private let screenBackground = Color(red: 0.09, green: 0.12, blue: 0.28)

    var body: some View {
        VStack(spacing: 16) {
            Text("Деталі")
                .font(.title2)
                .bold()

            Button("Лоббі: деталі в іншій вкладці") {
                router.selectTab(.browse, setStack: [.browseRoot, .browseDetails], animated: true)
            }

            Button("Назад може бути стандартним pop у цій вкладці") {

            }
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}

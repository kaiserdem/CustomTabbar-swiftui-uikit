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
            
            ContentView2()
        }
        .padding()
        .tabScreenChrome(background: screenBackground)
    }
}
struct ContentView2: View {
    @Namespace private var myNamespace
    @State private var isExpanded = false

    var body: some View {
        VStack {
            if isExpanded {
                Rectangle() // Цільовий View
                    //.matchedGeometryEffect(id: "myShape", in: myNamespace)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.blue)
            } else {
                Circle() // Вихідний View
                   // .matchedGeometryEffect(id: "myShape", in: myNamespace)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.red)
            }
            
            Button("Анімувати!") {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }
        }
        .padding()
    }
}

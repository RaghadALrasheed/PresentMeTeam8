//
//  Lama.swift
//  PresentMeTeam8
//
//  Created by lama farhan on 11/05/1448 AH.
//

import Foundation
import SwiftUI

struct ContentView3: View {
    let title: String = "Great Job!"
    let minutes: Int = 5
    let isOnline: Bool = true

    var body: some View {
        List {
            // MARK: - Header: image + title
            Section {
                VStack(spacing: 12) {
                    if isOnline {
                    Image(.walkingr)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 160)
                    } else {
                        Image(systemName: "moon.zzz.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 160)
                            .foregroundStyle(.gray)
                    }

                    Text(isOnline ? "Online" : "Offline")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(isOnline ? .green : .gray)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            // MARK: - bio
            Section("bio") {
                VStack(spacing: 8) {
                    Text("my name is lama ")
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ContentView3()
}

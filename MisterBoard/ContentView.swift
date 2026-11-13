//
//  ContentView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            RosaView()
                .tabItem {
                    Label("Rosa", systemImage: "person.3.fill")
                }
            
            PartiteView()
                .tabItem {
                    Label("Convocazioni", systemImage: "sportscourt.fill")
                }
            
            AllenamentiView()
                .tabItem {
                    Label("Allenamenti", systemImage: "figure.run")
                }
            
            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "trophy.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//


// TODO: Quando la partira è in casa, non deve comparire Ritrovo nell'export
// TODO: Creare video e banner

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
                    Label("Partite", systemImage: "sportscourt.fill")
                }
            
            AllenamentiView()
                .tabItem {
                    Label("Allenamenti", systemImage: "figure.run")
                }
            
            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "trophy.fill")
                }
            HelpView()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}

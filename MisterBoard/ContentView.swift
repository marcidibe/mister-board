//
//  ContentView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

// TODO:
    // 1 - ridurre dimensione card nomi giocatori
    // ** 2 - button cancella tutto con alert su allenamenti e partite --> FATTO **
    // 3 - quando la partira è in casa, non deve comparire Ritrovo nell'export
    // 4 - non funziona export
    // ** 5 - aggiungere guida dettagliata per utilizzo --> FATTO **
    // 6 - creare video e banner
    // 7 - creare suggerimenti

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HelpView()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
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

//
//  MisterBoardApp.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI
import SwiftData

@main
struct MisterBoardApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RosaAnnata.self,
            Giocatore.self,
            Partita.self,
            Allenamento.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

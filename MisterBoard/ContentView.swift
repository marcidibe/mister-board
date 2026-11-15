//
//  ContentView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RosaAnnata.annata) private var rose: [RosaAnnata]
    @AppStorage("rosaSelezionata") private var rosaSelezionata = ""
    @State private var pronto = false
    @State private var selezioneVuota = UUID()
    @State private var errore: String?

    private var selezione: Binding<UUID>? {
        guard let rosa = rose.first(where: { $0.id.uuidString == rosaSelezionata }) ?? rose.first else { return nil }
        return Binding(get: { rosa.id }, set: { rosaSelezionata = $0.uuidString })
    }

    var body: some View {
        Group {
            if pronto, let selezione { 
                schede(selezione: selezione)
            } else if pronto {
                NavigationStack {
                    ScrollView {
                        SelettoreAnnataView(selezione: $selezioneVuota, consenteGestione: true)
                            .frame(maxWidth: 540)
                            .frame(maxWidth: .infinity)
                            .padding(24)
                    }
                    .background(BoardPalette.rosa.opacity(0.045).ignoresSafeArea())
                    .navigationTitle("MisterBoard")
                    .navigationBarTitleDisplayMode(.inline)
                }
            } else if let errore {
                ContentUnavailableView {
                    Label("Impossibile caricare le rose", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errore)
                } actions: {
                    Button("Riprova") { preparaRose() }
                }
            } else {
                ProgressView("Preparazione rose…")
            }
        }
        .task { preparaRose() }
    }

    private func preparaRose() {
        do {
            try MigrazioneRose.prepara(in: modelContext)
            errore = nil
            pronto = true
        } catch {
            errore = error.localizedDescription
        }
    }

    private func schede(selezione: Binding<UUID>) -> some View {
        TabView {
            RosaView(selezione: selezione)
                .id(selezione.wrappedValue)
                .tabItem {
                    Label("Rose", systemImage: "person.3.fill")
                }
            
            PartiteView(selezione: selezione)
                .id(selezione.wrappedValue)
                .tabItem {
                    Label("Partite", systemImage: "sportscourt.fill")
                }
            
            AllenamentiView(selezione: selezione)
                .id(selezione.wrappedValue)
                .tabItem {
                    Label("Allenamenti", systemImage: "figure.run")
                }
            
            RankingView(selezione: selezione)
                .id(selezione.wrappedValue)
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

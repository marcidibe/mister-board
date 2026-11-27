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
    private enum Scheda: Hashable {
        case rose, partite, allenamenti, ranking, info
    }

    @State private var schedaSelezionata: Scheda = .rose
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
                            .frame(maxWidth: .infinity, alignment: .leading)
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
        TabView(selection: $schedaSelezionata) {
            Tab("Rose", systemImage: "person.3.fill", value: Scheda.rose) {
                RosaView(selezione: selezione)
                    .id(selezione.wrappedValue)
            }
            Tab("Partite", systemImage: "sportscourt.fill", value: Scheda.partite) {
                PartiteView(selezione: selezione)
                    .id(selezione.wrappedValue)
            }
            Tab("Allenamenti", systemImage: "figure.run", value: Scheda.allenamenti) {
                AllenamentiView(selezione: selezione)
                    .id(selezione.wrappedValue)
            }
            Tab("Ranking", systemImage: "trophy.fill", value: Scheda.ranking) {
                RankingView(selezione: selezione)
                    .id(selezione.wrappedValue)
            }
            Tab("Info", systemImage: "info.circle", value: Scheda.info) {
                HelpView()
            }
        }
    }
}

#Preview {
    ContentView()
}

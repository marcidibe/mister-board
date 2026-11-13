//
//  PartiteView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI
import SwiftData

struct PartiteView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Partita.dataOra, order: .reverse) private var partite: [Partita]
    @State private var mostraConfermaCancellaTutto = false
    
    var body: some View {
        NavigationStack {
            List {
                BoardSummaryCard(
                    title: "Le tue convocazioni",
                    subtitle: "Tutto inizia qui",
                    symbol: "sportscourt.fill",
                    color: BoardPalette.partite,
                    count: partite.count
                )
                
                ForEach(partite) { partita in
                    NavigationLink(destination: DettaglioPartitaView(partita: partita)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                BoardIcon(symbol: "sportscourt.fill", color: BoardPalette.partite)
                                Text(partita.tipo.titolo)
                                    .font(.headline)
                                Spacer()
                                Text(partita.inCasa ? "CASA" : "FUORI CASA")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(partita.inCasa ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                    .foregroundStyle(partita.inCasa ? .green : .orange)
                                    .clipShape(Capsule())
                            }
                            
                            if !partita.inCasa && !partita.luogo.isEmpty {
                                Label(partita.luogo, systemImage: "mappin.and.ellipse")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text(partita.dataOra.formatted(date: .abbreviated, time: .shortened))
                                Spacer()
                                Text("Convocati: \(partita.convocati.count)")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.blue)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: eliminaPartite)
                .boardCardRow(BoardPalette.partite)
            }
            .boardList(BoardPalette.partite)
            //.navigationTitle("Convocazioni")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        mostraConfermaCancellaTutto = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Elimina tutto")
                        }
                        .font(.caption.weight(.semibold))
                    }
                    .disabled(partite.isEmpty)
                    .accessibilityLabel("Cancella tutte le partite")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        creaNuovaPartita()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Nuova partita")
                        }
                        .font(.caption.weight(.semibold))
                    }
                    .accessibilityLabel("Nuova partita")
                }
            }
            .alert("Eliminare tutte le partite?", isPresented: $mostraConfermaCancellaTutto) {
                Button("Annulla", role: .cancel) {}
                Button("Elimina tutto", role: .destructive) {
                    cancellaTutteLePartite()
                }
            } message: {
                Text("Stai per cancellare TUTTE le partite. L'operazione non può essere annullata.")
            }
        }

    }
    
    private func creaNuovaPartita() {
        let nuova = Partita(dataOra: .now, inCasa: true, luogo: "")
        modelContext.insert(nuova)
    }
    
    private func eliminaPartite(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(partite[index])
        }
    }

    private func cancellaTutteLePartite() {
        for partita in partite {
            modelContext.delete(partita)
        }
    }
}

struct DettaglioPartitaView: View {
    @Bindable var partita: Partita
    @Query(sort: \Giocatore.cognome) private var rosa: [Giocatore]
    
    @State private var mostraAnteprimaCondivisione = false
    @State private var messaggioModificabile = ""
    
    private var tuttiConvocati: Bool {
        !rosa.isEmpty && partita.convocati.count == rosa.count
    }
    
    var body: some View {
        Form {
            Section("Dettagli Partita") {
                Picker("Tipo di partita", selection: $partita.tipo) {
                    Text("TORNEO").tag(TipoPartita.torneo)
                    Text("AMICHEVOLE").tag(TipoPartita.amichevole)
                    Text("CAMPIONATO").tag(TipoPartita.campionato)
                }
                .pickerStyle(.menu)

                DatePicker("Data e Ora", selection: $partita.dataOra)
                
                Picker("Dove si gioca", selection: $partita.inCasa.animation()) {
                    Text("In Casa").tag(true)
                    Text("Fuori Casa").tag(false)
                }
                .pickerStyle(.segmented)
                
                if !partita.inCasa {
                    TextField("Campo / Indirizzo trasferta", text: $partita.luogo)
                }
            }
            
            Section {
                ForEach(rosa) { giocatore in
                    Button {
                        toggleConvocazione(per: giocatore)
                    } label: {
                        HStack {
                            Text(giocatore.nomeCompleto)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: isConvocato(giocatore) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isConvocato(giocatore) ? .green : .secondary)
                                .font(.title3)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Convocati (\(partita.convocati.count)/\(rosa.count))")
                    Spacer()
                    if !rosa.isEmpty {
                        Button(tuttiConvocati ? "Deseleziona tutti" : "Seleziona tutti") {
                            toggleTutti()
                        }
                        .font(.caption)
                        .textCase(nil)
                    }
                }
            }
        }
        .boardList(BoardPalette.partite)
        .navigationTitle("Dettaglio Partita")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    preparaMessaggio()
                    mostraAnteprimaCondivisione = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Prepara messaggio")
                    }
                }
            }
        }
        .sheet(isPresented: $mostraAnteprimaCondivisione) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Puoi modificare liberamente il testo prima di inviarlo:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $messaggioModificabile)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding()
                .navigationTitle("Messaggio Convocati")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Chiudi") {
                            mostraAnteprimaCondivisione = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        ShareLink(item: messaggioModificabile) {
                            Label("Invia", systemImage: "paperplane.fill")
                        }
                    }
                }
            }
        }
    }
    
    private func preparaMessaggio() {
        let dataFormattata = partita.dataOra.formatted(date: .long, time: .shortened)
        let ordinati = partita.convocati.sorted { $0.cognome < $1.cognome }
        
        var testo = "⚽️ *CONVOCAZIONI: \(String(localized: partita.tipo.titolo))*\n"
        testo += "📅 \(dataFormattata)\n"
        
        if partita.inCasa {
            testo += "🏟️ Campo: In Casa\n"
        } else {
            let destinazione = partita.luogo.trimmingCharacters(in: .whitespaces).isEmpty ? "Da definire" : partita.luogo
            testo += "🚌 Campo: Fuori Casa (\(destinazione))\n"
        }
        
        testo += "\n"
        
        if ordinati.isEmpty {
            testo += "Nessun giocatore selezionato."
        } else {
            for (index, giocatore) in ordinati.enumerated() {
                testo += "\(index + 1). \(giocatore.nomeCompleto)\n"
            }
        }
        
        testo += "\n⏰ Ritrovo: "
        messaggioModificabile = testo
    }
    
    private func isConvocato(_ giocatore: Giocatore) -> Bool {
        partita.convocati.contains(where: { $0.id == giocatore.id })
    }
    
    private func toggleConvocazione(per giocatore: Giocatore) {
        if let index = partita.convocati.firstIndex(where: { $0.id == giocatore.id }) {
            partita.convocati.remove(at: index)
        } else {
            partita.convocati.append(giocatore)
        }
    }
    
    private func toggleTutti() {
        if tuttiConvocati {
            partita.convocati.removeAll()
        } else {
            partita.convocati = rosa
        }
    }
}


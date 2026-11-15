//
//  PartiteView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct PartiteView: View {
    @Binding var selezione: UUID

    init(selezione: Binding<UUID>) {
        _selezione = selezione
        let rosaID: UUID? = selezione.wrappedValue
        _partite = Query(filter: #Predicate<Partita> { $0.rosaID == rosaID }, sort: \Partita.dataOra, order: .reverse)
    }

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Partita.dataOra, order: .reverse) private var partite: [Partita]
    @State private var mostraConfermaCancellaTutto = false
    
    var body: some View {
        NavigationStack {
            List {
                SelettoreAnnataView(selezione: $selezione, consenteGestione: false)

                BoardSummaryCard(
                    title: "Le tue partite",
                    subtitle: "Tutto inizia qui",
                    symbol: "sportscourt.fill",
                    color: BoardPalette.partite,
                    count: partite.count
                )
                
                if partite.isEmpty {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.title3)
                            .foregroundStyle(BoardPalette.partite)
                            .padding(10)
                            .background(BoardPalette.partite.opacity(0.12), in: Circle())
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pronti a scendere in campo?")
                                .font(.subheadline.weight(.semibold))
                            Text("Tocca “Nuova partita” in alto per creare la prima partita e scegliere i convocati.\n\nPer cancellare una singola voce, scorri sulla sua riga da destra verso sinistra e tocca “Elimina”.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

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
                                Text(partita.dataOra.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(Locale(identifier: "it_IT"))))
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
                        .font(.caption2.weight(.semibold))
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
                        .font(.caption2.weight(.semibold))
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
                Text("Stai per cancellare TUTTE le partite della rosa selezionata. L'operazione non può essere annullata.")
            }
        }

    }
    
    private func creaNuovaPartita() {
        let nuova = Partita(dataOra: .now, inCasa: true, luogo: "")
        nuova.rosaID = selezione
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

private struct MessaggioCondivisione: Identifiable {
    let id = UUID()
    let testo: String
}

private struct CondivisioneMessaggioView: UIViewControllerRepresentable {
    let testo: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Passa il testo corrente direttamente alle app di destinazione.
        UIActivityViewController(activityItems: [testo], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DettaglioPartitaView: View {
    @Environment(\.dismiss) private var dismiss
    init(partita: Partita) {
        self.partita = partita
        let rosaID = partita.rosaID
        _rosa = Query(filter: #Predicate<Giocatore> { $0.rosaID == rosaID }, sort: \Giocatore.cognome)
    }

    @Bindable var partita: Partita
    @Query(sort: \Giocatore.cognome) private var rosa: [Giocatore]
    
    @State private var messaggioDaCondividere: MessaggioCondivisione?
    
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

                BoardDateTimePicker(selection: $partita.dataOra)
                
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
        //.navigationTitle("Dettaglio Partita")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Torna alle partite") {
                    dismiss()
                }
                .font(.caption.weight(.semibold))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    messaggioDaCondividere = MessaggioCondivisione(testo: preparaMessaggio())
                } label: {
                    Label("Condividi", systemImage: "square.and.arrow.up")
                        .font(.caption.weight(.semibold))
                }
            }
        }
        .sheet(item: $messaggioDaCondividere) { messaggio in
            CondivisioneMessaggioView(testo: messaggio.testo)
        }
    }
    
    private func preparaMessaggio() -> String {
        let dataFormattata = partita.dataOra.formatted(Date.FormatStyle(date: .long, time: .shortened).locale(Locale(identifier: "it_IT")))
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
        
        testo += partita.inCasa ? "\n⏰ Ritrovo: In Casa" : "\n⏰ Ritrovo: "
        return testo
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


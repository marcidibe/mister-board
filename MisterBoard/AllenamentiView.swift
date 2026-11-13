//
//  AllenamentiView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI
import SwiftData

struct AllenamentiView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Allenamento.dataOra, order: .reverse) private var allenamenti: [Allenamento]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allenamenti) { allenamento in
                    NavigationLink(destination: DettaglioAllenamentoView(allenamento: allenamento)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(allenamento.dataOra.formatted(date: .abbreviated, time: .shortened))
                                .font(.headline)
                            HStack {
                                Text(allenamento.note.isEmpty ? "Sessione ordinaria" : allenamento.note)
                                Spacer()
                                Text("Presenti: \(allenamento.presenti.count)")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.green)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: eliminaAllenamenti)
            }
            .navigationTitle("Allenamenti")
            .toolbar {
                Button {
                    let nuovo = Allenamento(dataOra: .now)
                    modelContext.insert(nuovo)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func eliminaAllenamenti(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(allenamenti[index])
        }
    }
}

struct DettaglioAllenamentoView: View {
    @Bindable var allenamento: Allenamento
    @Query(sort: \Giocatore.cognome) private var rosa: [Giocatore]
    
    private var tuttiPresenti: Bool {
        !rosa.isEmpty && allenamento.presenti.count == rosa.count
    }
    
    var body: some View {
        Form {
            Section("Dettagli Sessione") {
                DatePicker("Data e Ora", selection: $allenamento.dataOra)
                TextField("Note (es. Atletica, Partitella...)", text: $allenamento.note)
            }
            
            Section {
                ForEach(rosa) { giocatore in
                    Button {
                        togglePresenza(per: giocatore)
                    } label: {
                        HStack {
                            Text(giocatore.nomeCompleto)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: isPresente(giocatore) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isPresente(giocatore) ? .green : .secondary)
                                .font(.title3)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Presenti (\(allenamento.presenti.count)/\(rosa.count))")
                    Spacer()
                    if !rosa.isEmpty {
                        Button(tuttiPresenti ? "Deseleziona tutti" : "Seleziona tutti") {
                            toggleTutti()
                        }
                        .font(.caption)
                        .textCase(nil)
                    }
                }
            }
        }
        .navigationTitle("Presenze Allenamento")
    }
    
    private func isPresente(_ giocatore: Giocatore) -> Bool {
        allenamento.presenti.contains(where: { $0.id == giocatore.id })
    }
    
    private func togglePresenza(per giocatore: Giocatore) {
        if let index = allenamento.presenti.firstIndex(where: { $0.id == giocatore.id }) {
            allenamento.presenti.remove(at: index)
        } else {
            allenamento.presenti.append(giocatore)
        }
    }
    
    private func toggleTutti() {
        if tuttiPresenti {
            allenamento.presenti.removeAll()
        } else {
            allenamento.presenti = rosa
        }
    }
}

//
//  RosaView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI
import SwiftData

struct RosaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Giocatore.cognome) private var rosa: [Giocatore]
    
    @State private var testoRicerca = ""
    @State private var mostraAggiuntaSingola = false
    @State private var mostraImportazione = false
    
    @State private var nome = ""
    @State private var cognome = ""
    @State private var testoImportazione = ""
    
    @State private var giocatoreInModifica: Giocatore?
    @State private var nomeModifica = ""
    @State private var cognomeModifica = ""
    
    private var rosaFiltrata: [Giocatore] {
        let query = testoRicerca.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return rosa
        }
        return rosa.filter { giocatore in
            giocatore.nomeCompleto.localizedStandardContains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(rosaFiltrata) { giocatore in
                    Button {
                        apriModifica(per: giocatore)
                    } label: {
                        HStack {
                            Text(giocatore.nomeCompleto)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: eliminaGiocatori)
            }
            .navigationTitle("Rosa (\(rosa.count))")
            .searchable(text: $testoRicerca, prompt: "Cerca per nome o cognome")
            .overlay {
                if rosaFiltrata.isEmpty && !testoRicerca.isEmpty {
                    ContentUnavailableView.search(text: testoRicerca)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        mostraImportazione = true
                    } label: {
                        Label("Importa lista", systemImage: "doc.on.clipboard")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mostraAggiuntaSingola = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Nuovo Giocatore", isPresented: $mostraAggiuntaSingola) {
                TextField("Nome", text: $nome)
                TextField("Cognome", text: $cognome)
                Button("Annulla", role: .cancel) { resetCampi() }
                Button("Aggiungi") {
                    aggiungiSingolo()
                }
            }
            .alert("Modifica Giocatore", isPresented: Binding(
                get: { giocatoreInModifica != nil },
                set: { if !$0 { giocatoreInModifica = nil } }
            )) {
                TextField("Nome", text: $nomeModifica)
                TextField("Cognome", text: $cognomeModifica)
                Button("Annulla", role: .cancel) {
                    giocatoreInModifica = nil
                }
                Button("Salva") {
                    salvaModifica()
                }
            }
            .sheet(isPresented: $mostraImportazione) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Incolla qui l'elenco dei giocatori (uno per riga, formato: Nome Cognome):")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $testoImportazione)
                            .border(Color.secondary.opacity(0.3))
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .navigationTitle("Importa Rosa")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annulla") {
                                testoImportazione = ""
                                mostraImportazione = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Importa") {
                                importaDaTesto()
                                mostraImportazione = false
                            }
                            .disabled(testoImportazione.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func apriModifica(per giocatore: Giocatore) {
        nomeModifica = giocatore.nome
        cognomeModifica = giocatore.cognome
        giocatoreInModifica = giocatore
    }
    
    private func salvaModifica() {
        guard let giocatore = giocatoreInModifica else { return }
        let n = nomeModifica.trimmingCharacters(in: .whitespaces)
        let c = cognomeModifica.trimmingCharacters(in: .whitespaces)
        if !n.isEmpty || !c.isEmpty {
            giocatore.nome = n
            giocatore.cognome = c
        }
        giocatoreInModifica = nil
    }
    
    private func aggiungiSingolo() {
        let n = nome.trimmingCharacters(in: .whitespaces)
        let c = cognome.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty || !c.isEmpty else { return }
        
        let nuovo = Giocatore(nome: n, cognome: c)
        modelContext.insert(nuovo)
        resetCampi()
    }
    
    private func importaDaTesto() {
        let righe = testoImportazione.components(separatedBy: .newlines)
        for riga in righe {
            let pulita = riga.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !pulita.isEmpty else { continue }
            
            let parti = pulita.split(separator: " ", maxSplits: 1)
            let nomeEstratto = String(parti[0])
            let cognomeEstratto = parti.count > 1 ? String(parti[1]) : ""
            
            modelContext.insert(Giocatore(nome: nomeEstratto, cognome: cognomeEstratto))
        }
        testoImportazione = ""
    }
    
    private func eliminaGiocatori(offsets: IndexSet) {
        for index in offsets {
            let giocatoreDaEliminare = rosaFiltrata[index]
            modelContext.delete(giocatoreDaEliminare)
        }
    }
    
    private func resetCampi() {
        nome = ""
        cognome = ""
    }
}

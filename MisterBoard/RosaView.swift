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
    @State private var mostraErroreImportazione = false
    
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
                BoardSummaryCard(title: "La tua squadra", subtitle: "Giocatori pronti a scendere in campo", symbol: "person.3.fill", color: BoardPalette.rosa, count: rosa.count)
                ForEach(rosaFiltrata) { giocatore in
                    Button {
                        apriModifica(per: giocatore)
                    } label: {
                        HStack(spacing: 14) {
                            BoardIcon(symbol: "person.fill", color: BoardPalette.rosa)
                            Text(giocatore.nomeCompleto)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: eliminaGiocatori)
                .boardCardRow(BoardPalette.rosa)
            }
            .boardList(BoardPalette.rosa)
            .navigationTitle("Rosa")
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
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                TextField("Cognome", text: $cognome)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
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
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                TextField("Cognome", text: $cognomeModifica)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
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
                        Text("Incolla un giocatore per riga nel formato NOME COGNOME: due parole di sole lettere separate da un solo spazio. Il testo verrà convertito in maiuscolo.")
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
                            }
                            .disabled(testoImportazione.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .alert("Lista non valida", isPresented: $mostraErroreImportazione) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("La lista caricata non rispetta le regole richieste. Inserisci un giocatore per riga nel formato NOME COGNOME: due parole di sole lettere separate da un solo spazio, senza numeri, simboli o righe vuote. Nessun giocatore è stato importato.")
                }
            }
        }
        .onChange(of: nome) { _, valore in
            nome = TestoAnagrafico.normalizza(valore)
        }
        .onChange(of: cognome) { _, valore in
            cognome = TestoAnagrafico.normalizza(valore)
        }
        .onChange(of: nomeModifica) { _, valore in
            nomeModifica = TestoAnagrafico.normalizza(valore)
        }
        .onChange(of: cognomeModifica) { _, valore in
            cognomeModifica = TestoAnagrafico.normalizza(valore)
        }
    }
    
    private func apriModifica(per giocatore: Giocatore) {
        nomeModifica = giocatore.nome
        cognomeModifica = giocatore.cognome
        giocatoreInModifica = giocatore
    }
    
    private func salvaModifica() {
        guard let giocatore = giocatoreInModifica else { return }
        let n = TestoAnagrafico.normalizza(nomeModifica).trimmingCharacters(in: .whitespaces)
        let c = TestoAnagrafico.normalizza(cognomeModifica).trimmingCharacters(in: .whitespaces)
        if !n.isEmpty || !c.isEmpty {
            giocatore.nome = n
            giocatore.cognome = c
        }
        giocatoreInModifica = nil
    }
    
    private func aggiungiSingolo() {
        let n = TestoAnagrafico.normalizza(nome).trimmingCharacters(in: .whitespaces)
        let c = TestoAnagrafico.normalizza(cognome).trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty || !c.isEmpty else { return }
        
        let nuovo = Giocatore(nome: n, cognome: c)
        modelContext.insert(nuovo)
        resetCampi()
    }
    
    private func importaDaTesto() {
        testoImportazione = testoImportazione.uppercased()
        guard let giocatori = TestoAnagrafico.validaLista(testoImportazione) else {
            mostraErroreImportazione = true
            return
        }

        for giocatore in giocatori {
            modelContext.insert(Giocatore(nome: giocatore.nome, cognome: giocatore.cognome))
        }
        testoImportazione = ""
        mostraImportazione = false
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

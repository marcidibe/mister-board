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
    @State private var mostraDuplicatiImportazione = false
    @State private var duplicatiImportazione: [String] = []
    
    @State private var giocatoreInModifica: Giocatore?
    @State private var nomeModifica = ""
    @State private var cognomeModifica = ""
    @State private var mostraConfermaCancellaTutto = false

    private func cancellaTuttiIGiocatori() {
        for giocatore in rosa {
            modelContext.delete(giocatore)
        }
    }
    
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
                BoardSummaryCard(
                    title: "La tua Rosa",
                    subtitle: "Atleti a disposizione",
                    symbol: "person.3.fill",
                    color: BoardPalette.rosa,
                    count: rosa.count
                )
                
                if rosa.isEmpty {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.title3)
                            .foregroundStyle(BoardPalette.rosa)
                            .padding(10)
                            .background(BoardPalette.rosa.opacity(0.12), in: Circle())
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dai forma alla tua squadra!")
                                .font(.subheadline.weight(.semibold))
                            Text("Tocca “Nuovo giocatore” in alto per aggiungere il primo atleta, oppure scegli “Importa una lista” dal menu “Gestisci”.\n\nPer cancellare una singola voce, scorri sulla sua riga da destra verso sinistra e tocca “Elimina”.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                ForEach(rosaFiltrata) { giocatore in
                    Button {
                        apriModifica(per: giocatore)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(BoardPalette.rosa)
                                .padding(7)
                                .background(BoardPalette.rosa.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                                .accessibilityHidden(true)
                            Text(giocatore.nomeCompleto)
                                .font(.footnote)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .truncationMode(.tail)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "pencil")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: eliminaGiocatori)
                .boardCardRow(BoardPalette.rosa, compact: true)
            }
            .boardList(BoardPalette.rosa)
            //.navigationTitle("Rosa")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            mostraImportazione = true
                        } label: {
                            Label("Importa una lista", systemImage: "doc.on.clipboard")
                        }
                        
                        if !rosa.isEmpty {
                            Divider()
                            Button(role: .destructive) {
                                mostraConfermaCancellaTutto = true
                            } label: {
                                Label("Cancella tutta la rosa", systemImage: "trash")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "ellipsis.circle")
                            Text("Gestisci")
                        }
                        .font(.caption.weight(.semibold))
                    }
                    .accessibilityLabel("Gestisci lista giocatori")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mostraAggiuntaSingola = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Nuovo giocatore")
                        }
                        .font(.caption.weight(.semibold))
                    }
                    .accessibilityLabel("Aggiungi giocatore")
                }
            }
            .alert("Eliminare tutta la rosa?", isPresented: $mostraConfermaCancellaTutto) {
                Button("Annulla", role: .cancel) {}
                Button("Elimina tutto", role: .destructive) {
                    cancellaTuttiIGiocatori()
                }
            } message: {
                Text("Stai per cancellare TUTTI i giocatori della rosa. L'operazione non può essere annullata.")
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
                .disabled(esisteGiocatore(nome: nome, cognome: cognome))
            } message: {
                if esisteGiocatore(nome: nome, cognome: cognome) {
                    Text("Questo giocatore è già presente nella rosa.")
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
                .disabled(esisteGiocatore(nome: nomeModifica, cognome: cognomeModifica, escluso: giocatoreInModifica))
            } message: {
                if esisteGiocatore(nome: nomeModifica, cognome: cognomeModifica, escluso: giocatoreInModifica) {
                    Text("Un altro giocatore ha già questo nome e cognome.")
                }
            }
            .sheet(isPresented: $mostraImportazione) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Inserisci un giocatore per riga, ad esempio MARIO DI DATO. La prima parola è il nome, le successive sono il cognome. Usa solo lettere e un singolo spazio tra le parole.")
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
                .alert("Giocatori duplicati", isPresented: $mostraDuplicatiImportazione) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Questi giocatori sono già nella rosa o ripetuti nella lista:\n\n\(duplicatiImportazione.joined(separator: "\n"))\n\nRimuovi i duplicati e riprova. Nessun giocatore è stato importato.")
                }
                .alert("Lista non valida", isPresented: $mostraErroreImportazione) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Inserisci nome e cognome per ogni riga, ad esempio MARIO DI DATO. La prima parola è il nome, le successive sono il cognome. Usa solo lettere e un singolo spazio tra le parole, senza righe vuote. Nessun giocatore è stato importato.")
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


    
    private func esisteGiocatore(nome: String, cognome: String, escluso: Giocatore? = nil) -> Bool {
        let chiave = TestoAnagrafico.chiave(
            nome: TestoAnagrafico.normalizza(nome),
            cognome: TestoAnagrafico.normalizza(cognome)
        )
        return rosa.contains {
            $0.id != escluso?.id &&
            TestoAnagrafico.chiave(nome: $0.nome, cognome: $0.cognome) == chiave
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
        guard !esisteGiocatore(nome: n, cognome: c, escluso: giocatore) else { return }
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
        
        guard !esisteGiocatore(nome: n, cognome: c) else { return }
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

        // Verifica l'intera lista prima di inserire, evitando importazioni parziali.
        var chiavi = Set(rosa.map { TestoAnagrafico.chiave(nome: $0.nome, cognome: $0.cognome) })
        var chiaviDuplicate = Set<[String]>()
        duplicatiImportazione = []
        for giocatore in giocatori {
            let chiave = TestoAnagrafico.chiave(nome: giocatore.nome, cognome: giocatore.cognome)
            if !chiavi.insert(chiave).inserted && chiaviDuplicate.insert(chiave).inserted {
                duplicatiImportazione.append("\(giocatore.nome) \(giocatore.cognome)")
            }
        }
        if !duplicatiImportazione.isEmpty {
            mostraDuplicatiImportazione = true
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


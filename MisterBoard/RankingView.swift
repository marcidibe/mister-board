import SwiftUI
import SwiftData
import Charts

struct RankingView: View {
    @Binding var selezione: UUID

    init(selezione: Binding<UUID>) {
        _selezione = selezione
        let rosaID: UUID? = selezione.wrappedValue
        _giocatori = Query(filter: #Predicate<Giocatore> { $0.rosaID == rosaID }, sort: \Giocatore.cognome)
        _partite = Query(filter: #Predicate<Partita> { $0.rosaID == rosaID }, sort: \Partita.dataOra, order: .reverse)
        _allenamenti = Query(filter: #Predicate<Allenamento> { $0.rosaID == rosaID }, sort: \Allenamento.dataOra, order: .reverse)
    }

    @Query private var giocatori: [Giocatore]
    @Query private var partite: [Partita]
    @Query private var allenamenti: [Allenamento]

    @State private var tipoRanking = 0
    @State private var ricerca = ""
    @State private var mostraZero = false

    private var totale: Int {
        tipoRanking == 0 ? allenamenti.count : partite.count
    }

    private var righe: [RigaPartecipazione] {
        let eventi = tipoRanking == 0
            ? Set(allenamenti.map(\.persistentModelID))
            : Set(partite.map(\.persistentModelID))
        let ordinate = giocatori.map { giocatore in
            let partecipazioni = tipoRanking == 0
                ? Set(giocatore.allenamentiPresenti.map(\.persistentModelID))
                : Set(giocatore.partiteConvocate.map(\.persistentModelID))
            return RigaPartecipazione(
                giocatore: giocatore,
                conteggio: partecipazioni.intersection(eventi).count
            )
        }.sorted {
            if $0.conteggio != $1.conteggio { return $0.conteggio > $1.conteggio }
            return $0.giocatore.nomeCompleto.localizedStandardCompare($1.giocatore.nomeCompleto) == .orderedAscending
        }
        let testo = ricerca.trimmingCharacters(in: .whitespacesAndNewlines)
        return ordinate.filter {
            (mostraZero || $0.conteggio > 0) &&
            (testo.isEmpty || $0.giocatore.nomeCompleto.localizedStandardContains(testo))
        }
    }

    var body: some View {
        let dati = righe

        NavigationStack {
            List {
                SelettoreAnnataView(selezione: $selezione, consenteGestione: false)

                BoardSummaryCard(
                    title: "Ogni presenza conta",
                    subtitle: "Giocatori nel ranking",
                    symbol: "chart.bar.xaxis",
                    color: BoardPalette.ranking,
                    count: giocatori.count
                )

                Picker("Tipo Ranking", selection: $tipoRanking) {
                    Text("Allenamenti").tag(0)
                    Text("Convocazioni").tag(1)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section {
                    Toggle("Mostra anche chi è a zero", isOn: $mostraZero)
                        .font(.footnote)
                } footer: {
                    Text(tipoRanking == 0
                         ? "Percentuale degli allenamenti registrati a cui il giocatore è presente. 8 presenze su 10 allenamenti = 80%."
                         : "Percentuale delle partite registrate per cui il giocatore è convocato. 8 convocazioni su 10 partite = 80%.")
                }

                if totale == 0 {
                    ContentUnavailableView(
                        "Nessun evento registrato",
                        systemImage: "chart.bar",
                        description: Text(tipoRanking == 0
                                          ? "Aggiungi un allenamento e registra le presenze per questa annata."
                                          : "Aggiungi una partita e scegli i convocati per questa annata.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(dati) { riga in
                            BarraPartecipazioneView(
                                riga: riga,
                                totale: totale,
                                convocazioni: tipoRanking == 1
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.orange.opacity(0.10).gradient)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(Color.orange.opacity(0.18), lineWidth: 1)
                                    }
                            }
                            // Lascia spazio tra la card e il ritaglio della sezione.
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        if dati.isEmpty {
                            Text("Nessun giocatore corrisponde ai filtri. Prova a modificare la ricerca o a mostrare anche chi è a zero.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(tipoRanking == 0 ? "Presenze agli allenamenti" : "Convocazioni alle partite")
                            Text("\(totale) eventi · \(dati.count) giocatori visualizzati")
                                .font(.caption)
                        }
                        .textCase(nil)
                    }
                }
            }
            .boardList(BoardPalette.ranking)
            .searchable(text: $ricerca, prompt: "Cerca giocatore o identificativo")
        }
    }
}

private struct RigaPartecipazione: Identifiable {
    let giocatore: Giocatore
    let conteggio: Int
    var id: PersistentIdentifier { giocatore.persistentModelID }
}

private struct BarraPartecipazioneView: View {
    let riga: RigaPartecipazione
    let totale: Int
    let convocazioni: Bool

    private var percentuale: Double {
        totale > 0 ? Double(riga.conteggio) / Double(totale) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            NomeGiocatoreView(giocatore: riga.giocatore)
                .font(.footnote.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(convocazioni
                     ? "\(riga.conteggio) convocazioni su \(totale) partite"
                     : "\(riga.conteggio) presenze su \(totale) allenamenti")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 8)
                Text(percentuale, format: .percent.precision(.fractionLength(0...1)))
                    .font(.footnote.weight(.bold))
                    .monospacedDigit()
            }

            // Ogni riga usa la stessa scala: le barre sono confrontabili anche scorrendo.
            Chart {
                BarMark(
                    xStart: .value("Inizio", 0),
                    xEnd: .value("Massimo", 100),
                    y: .value("Giocatore", "partecipazione")
                )
                .foregroundStyle(BoardPalette.ranking.opacity(0.12))
                .cornerRadius(4)

                BarMark(
                    xStart: .value("Inizio", 0),
                    xEnd: .value("Percentuale", percentuale * 100),
                    y: .value("Giocatore", "partecipazione")
                )
                .foregroundStyle(BoardPalette.ranking.gradient)
                .cornerRadius(4)
            }
            .chartXScale(domain: 0...100)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 14)
            .accessibilityHidden(true)

            HStack {
                Text("0%")
                Spacer()
                Text("50%")
                Spacer()
                Text("100%")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
    }
}

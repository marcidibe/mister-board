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

    var giocatoriOrdinati: [Giocatore] {
        giocatori.sorted { g1, g2 in
            if tipoRanking == 0 {
                return g1.allenamentiPresenti.count > g2.allenamentiPresenti.count
            } else {
                return g1.partiteConvocate.count > g2.partiteConvocate.count
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                SelettoreAnnataView(selezione: $selezione, consenteGestione: false)

                BoardSummaryCard(title: "Ogni presenza conta", subtitle: "Giocatori nel ranking", symbol: "trophy.fill", color: BoardPalette.ranking, count: giocatori.count)

                Picker("Tipo Ranking", selection: $tipoRanking) {
                    Text("Allenamenti").tag(0)
                    Text("Convocazioni").tag(1)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                GraficoPartecipazioneView(giocatori: giocatori, tipoRanking: tipoRanking)
                    .boardCardRow(BoardPalette.ranking)

                ForEach(Array(giocatoriOrdinati.enumerated()), id: \.element.id) { index, giocatore in
                    RankingCard(
                        posizione: index + 1,
                        giocatore: giocatore,
                        conteggio: tipoRanking == 0 ? giocatore.allenamentiPresenti.count : giocatore.partiteConvocate.count,
                        totale: tipoRanking == 0 ? allenamenti.count : partite.count
                    )
                    .boardCardRow(BoardPalette.ranking, compact: true)
                }
            }
            .boardList(BoardPalette.ranking)
            //.navigationTitle("Ranking Squadra")
        }
    }
}

private struct QuotaGiocatore: Identifiable {
    let id: PersistentIdentifier
    let nome: String
    let iniziali: String
    let conteggio: Int
    let colore: Color
}

private struct GraficoPartecipazioneView: View {
    let giocatori: [Giocatore]
    let tipoRanking: Int

    private var quote: [QuotaGiocatore] {
        // L'ordine anagrafico mantiene gli stessi colori cambiando tipo di ranking.
        giocatori.enumerated().map { indice, giocatore in
            QuotaGiocatore(
                id: giocatore.persistentModelID,
                nome: giocatore.nomeCompleto,
                iniziali: [giocatore.nome, giocatore.cognome]
                    .compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).first }
                    .map { String($0).uppercased() }
                    .joined() + (giocatore.identificativoPulito.isEmpty ? "" : " · \(giocatore.identificativoPulito)"),
                conteggio: tipoRanking == 0 ? giocatore.allenamentiPresenti.count : giocatore.partiteConvocate.count,
                colore: Color(hue: (Double(indice) * 0.61803398875).truncatingRemainder(dividingBy: 1),
                              saturation: 0.65, brightness: 0.8)
            )
        }
    }

    var body: some View {
        let dati = quote
        let totale = dati.reduce(0) { $0 + $1.conteggio }
        let fette = dati.filter { $0.conteggio > 0 }

        VStack(alignment: .leading, spacing: 16) {
            Text(tipoRanking == 0 ? "Distribuzione delle presenze" : "Distribuzione delle convocazioni")
                .font(.headline)

            if totale == 0 {
                Label("Nessun dato da rappresentare", systemImage: "chart.pie")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Registra le presenze o le convocazioni per visualizzare le quote dei giocatori.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Chart(fette) { quota in
                    SectorMark(
                        angle: .value("Partecipazioni", quota.conteggio),
                        innerRadius: .ratio(0),
                        angularInset: 1
                    )
                    .foregroundStyle(quota.colore)
                    .annotation(position: .overlay) {
                        Text(quota.iniziali)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel(quota.nome)
                    .accessibilityValue(
                        "\(quota.conteggio) partecipazioni, \((Double(quota.conteggio) / Double(totale)).formatted(.percent.precision(.fractionLength(1)))) del totale"
                    )
                }
                .frame(height: 260)
                .chartLegend(.hidden)

                Text("Ogni fetta indica la quota del giocatore sul totale delle partecipazioni registrate. Le percentuali nell’elenco del ranking indicano invece la partecipazione ai singoli eventi.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(dati) { quota in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle()
                            .fill(quota.colore)
                            .frame(width: 10, height: 10)
                            .accessibilityHidden(true)
                        Text(quota.nome)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 8)
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(Double(quota.conteggio) / Double(totale),
                                 format: .percent.precision(.fractionLength(1)))
                                .font(.footnote.weight(.semibold))
                            Text("\(quota.conteggio) su \(totale)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
                Text("I giocatori con zero partecipazioni non occupano una fetta.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct RankingCard: View {
    let posizione: Int
    let giocatore: Giocatore
    let conteggio: Int
    let totale: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(posizione, format: .number)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .padding(7)
                    .background(BoardPalette.ranking.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                NomeGiocatoreView(giocatore: giocatore)
                    .font(.footnote)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .truncationMode(.tail)
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(conteggio) / \(totale)")
                        .font(.caption.weight(.semibold))
                    Text("\(totale > 0 ? Int(Double(conteggio) / Double(totale) * 100) : 0)%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            ProgressView(value: Double(conteggio), total: Double(max(totale, conteggio, 1)))
                .tint(BoardPalette.ranking)
                .accessibilityLabel("Partecipazione")
        }
    }
}

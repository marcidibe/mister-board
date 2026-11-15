import SwiftUI
import SwiftData

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

                ForEach(Array(giocatoriOrdinati.enumerated()), id: \.element.id) { index, giocatore in
                    RankingCard(
                        posizione: index + 1,
                        nome: giocatore.nomeCompleto,
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

private struct RankingCard: View {
    let posizione: Int
    let nome: String
    let conteggio: Int
    let totale: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(posizione, format: .number)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .padding(7)
                    .background(BoardPalette.ranking.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                Text(nome)
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

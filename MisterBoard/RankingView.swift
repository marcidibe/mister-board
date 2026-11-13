import SwiftUI
import SwiftData

struct RankingView: View {
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
                    .boardCardRow(BoardPalette.ranking)
                }
            }
            .boardList(BoardPalette.ranking)
            .navigationTitle("Ranking Squadra")
        }
    }
}

private struct RankingCard: View {
    let posizione: Int
    let nome: String
    let conteggio: Int
    let totale: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text(posizione, format: .number)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .padding(12)
                    .background(BoardPalette.ranking.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                Text(nome)
                    .font(.headline)
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(conteggio) / \(totale)")
                        .fontWeight(.semibold)
                    Text("\(totale > 0 ? Int(Double(conteggio) / Double(totale) * 100) : 0)%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            ProgressView(value: Double(conteggio), total: Double(max(totale, conteggio, 1)))
                .tint(BoardPalette.ranking)
                .accessibilityLabel("Partecipazione")
        }
    }
}

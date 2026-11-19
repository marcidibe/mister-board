import SwiftUI

struct NomeGiocatoreView: View {
    let giocatore: Giocatore

    var body: some View {
        HStack(spacing: 6) {
            Text("\(giocatore.cognome) \(giocatore.nome)")
            if !giocatore.identificativoPulito.isEmpty {
                Text(giocatore.identificativoPulito)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.purple.opacity(0.16), in: Capsule())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(giocatore.nomeCompleto)
    }
}

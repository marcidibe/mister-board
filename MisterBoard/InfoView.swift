//
//  InfoView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Rosa") {
                    HelpRow(
                        iconName: "person.3.fill",
                        color: BoardPalette.rosa,
                        title: "Gestisci i giocatori",
                        description: "Tocca “Nuovo giocatore” per aggiungere un atleta. Se nome e cognome sono già presenti nella rosa, il tasto “Aggiungi” è disabilitato. Tocca un nome per modificarlo."
                    )
                    HelpRow(
                        iconName: "doc.on.clipboard",
                        color: BoardPalette.rosa,
                        title: "Importa una lista",
                        description: "Da “Gestisci”, scegli “Importa una lista”. Scrivi un giocatore per riga, ad esempio MARIO DI ROSSI: la prima parola è il nome, le successive sono il cognome. Usa solo lettere e un singolo spazio tra le parole, senza righe vuote. Se ci sono giocatori già presenti o ripetuti nella lista, un avviso blocca l’importazione: rimuovi i duplicati e riprova. Nessun giocatore viene importato."
                    )
                }

                Section("Partite") {
                    HelpRow(
                        iconName: "sportscourt.fill",
                        color: BoardPalette.partite,
                        title: "Organizza una partita",
                        description: "Tocca “Nuova partita”, poi aprila per scegliere tipo, data e ora. Indica se giochi in casa o fuori casa e il campo della trasferta."
                    )
                    HelpRow(
                        iconName: "checkmark.circle.fill",
                        color: BoardPalette.partite,
                        title: "Scegli i convocati",
                        description: "Tocca i giocatori da convocare oppure usa “Seleziona tutti”. Tocca di nuovo un nome per rimuoverlo."
                    )
                    HelpRow(
                        iconName: "square.and.arrow.up",
                        color: BoardPalette.partite,
                        title: "Condividi le convocazioni",
                        description: "Tocca “Condividi” nella partita per inviare i dettagli e l’elenco dei convocati."
                    )
                }

                Section("Allenamenti") {
                    HelpRow(
                        iconName: "figure.run",
                        color: BoardPalette.allenamenti,
                        title: "Registra una sessione di allenamento",
                        description: "Tocca “Nuovo allenamento”, poi aprilo per impostare data, ora e note."
                    )
                    HelpRow(
                        iconName: "checklist",
                        color: BoardPalette.allenamenti,
                        title: "Segna le presenze",
                        description: "Tocca i giocatori presenti oppure usa “Seleziona tutti”. Tocca di nuovo un nome per togliere la presenza."
                    )
                }

                Section("Ranking") {
                    HelpRow(
                        iconName: "trophy.fill",
                        color: BoardPalette.ranking,
                        title: "Consulta la partecipazione",
                        description: "Scegli “Allenamenti” o “Convocazioni” per ordinare i giocatori per presenze o convocazioni. Ogni riga mostra il conteggio e la percentuale sul totale."
                    )
                }

                Section("Gestione dati") {
                    HelpRow(
                        iconName: "trash",
                        color: .red,
                        title: "Elimina le voci",
                        description: "Scorri una riga verso sinistra per eliminarla. Per svuotare una sezione, usa “Elimina tutto” o “Gestisci” nella Rosa e conferma."
                    )
                    HelpRow(
                        iconName: "checkmark.shield.fill",
                        color: .blue,
                        title: "Salvataggio automatico",
                        description: "Giocatori, partite e allenamenti vengono salvati automaticamente e restano disponibili alla riapertura dell’app."
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Guida a MisterBoard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct HelpRow: View {
    let iconName: String
    let color: Color
    let title: LocalizedStringResource
    let description: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconName)
                .foregroundStyle(color)
                .font(.title2)
                .frame(width: 30)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HelpView()
}

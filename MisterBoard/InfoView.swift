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
                Section("Rose per annata") {
                    HelpRow(
                        iconName: "plus.circle.fill",
                        color: BoardPalette.rosa,
                        title: "Crea la tua prima rosa",
                        description: "Se non ci sono rose, tocca “Crea la prima rosa” nella schermata di benvenuto. Scegli un’annata univoca, ad esempio 2013 o 2026/2027, e salva. Per aggiungerne altre, nella scheda Rose tocca “Aggiungi una Nuova Rosa”."
                    )
                    HelpRow(
                        iconName: "calendar",
                        color: BoardPalette.rosa,
                        title: "Scegli e rinomina l’annata",
                        description: "Il selettore “Annata” è disponibile in Rose, Partite, Allenamenti e Ranking. La scelta è condivisa tra le schede: ciascuna mostra i dati della rosa selezionata. Nella scheda Rose, il titolo della card riporta l’annata; usa “Rinomina annata” per cambiarne il nome."
                    )
                    HelpRow(
                        iconName: "person.3.fill",
                        color: BoardPalette.rosa,
                        title: "Gestisci i giocatori",
                        description: "Tocca “Nuovo giocatore” per aggiungere un atleta alla rosa selezionata. Se nome e cognome sono già presenti in quella rosa, il tasto “Aggiungi” è disabilitato. Lo stesso nome può essere presente in rose diverse. Tocca un nome per modificarlo."
                    )
                    HelpRow(
                        iconName: "doc.on.clipboard",
                        color: BoardPalette.rosa,
                        title: "Importa una lista",
                        description: "Seleziona l’annata, poi da “Gestisci” scegli “Importa una lista”. Scrivi un giocatore per riga, ad esempio MARIO DI ROSSI: la prima parola è il nome, le successive sono il cognome. Usa solo lettere e un singolo spazio tra le parole, senza righe vuote. Se ci sono giocatori già presenti o ripetuti nella lista, un avviso blocca l’importazione: rimuovi i duplicati e riprova. Nessun giocatore viene importato."
                    )
                }

                Section("Partite") {
                    HelpRow(
                        iconName: "sportscourt.fill",
                        color: BoardPalette.partite,
                        title: "Organizza una partita",
                        description: "Seleziona l’annata e tocca “Nuova partita”: la partita appartiene a quella rosa. Aprila per scegliere tipo, data e ora. Indica se giochi in casa o fuori casa e il campo della trasferta."
                    )
                    HelpRow(
                        iconName: "checkmark.circle.fill",
                        color: BoardPalette.partite,
                        title: "Scegli i convocati",
                        description: "Sono disponibili solo i giocatori della rosa della partita. Tocca quelli da convocare oppure usa “Seleziona tutti”. Tocca di nuovo un nome per rimuoverlo."
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
                        description: "Seleziona l’annata e tocca “Nuovo allenamento”: la sessione appartiene a quella rosa. Aprila per impostare data, ora e note."
                    )
                    HelpRow(
                        iconName: "checklist",
                        color: BoardPalette.allenamenti,
                        title: "Segna le presenze",
                        description: "Sono disponibili solo i giocatori della rosa dell’allenamento. Tocca i presenti oppure usa “Seleziona tutti”. Tocca di nuovo un nome per togliere la presenza."
                    )
                }

                Section("Ranking") {
                    HelpRow(
                        iconName: "trophy.fill",
                        color: BoardPalette.ranking,
                        title: "Consulta la partecipazione",
                        description: "Seleziona l’annata, poi scegli “Allenamenti” o “Convocazioni” per ordinare i giocatori per presenze o convocazioni. Ogni riga mostra il conteggio e la percentuale sul totale degli eventi della rosa selezionata. Ogni rosa ha una classifica indipendente."
                    )
                }

                Section("Gestione dati") {
                    HelpRow(
                        iconName: "trash",
                        color: .red,
                        title: "Elimina le voci",
                        description: "Scorri una riga verso sinistra per eliminare un giocatore, una partita o un allenamento. In Partite e Allenamenti, “Elimina tutto” cancella solo gli eventi di quella sezione per la rosa selezionata, dopo conferma. Le altre rose restano invariate."
                    )
                    HelpRow(
                        iconName: "trash.circle.fill",
                        color: .red,
                        title: "Elimina una rosa",
                        description: "Nella scheda Rose, scegli l’annata e apri “Gestisci” → “Elimina rosa”. Dopo la conferma vengono eliminati l’annata e tutti i suoi giocatori, allenamenti e partite. L’annata scompare da tutti i selettori; le altre rose rimangono intatte. L’operazione non può essere annullata. Se elimini l’ultima rosa, torna la schermata per crearne una nuova."
                    )
                    HelpRow(
                        iconName: "checkmark.shield.fill",
                        color: .blue,
                        title: "Salvataggio automatico",
                        description: "Annate, giocatori, partite e allenamenti vengono salvati e restano disponibili alla riapertura dell’app. Anche la scelta dell’annata viene ricordata."
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

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
                HelpIntroView()

                Section("Rosa Giocatori") {
                    HelpRow(
                        iconName: "plus.circle.fill",
                        color: BoardPalette.rosa,
                        title: "Crea la tua prima rosa",
                        description: "Se non ci sono rose, tocca “Crea la prima rosa” nella schermata di benvenuto. Scegli un’annata univoca, ad esempio 2013 o 2026/2027, e salva. Per aggiungerne altre, nella scheda Rose tocca “Aggiungi una Nuova Rosa”."
                    )
                    HelpRow(
                        iconName: "calendar",
                        color: BoardPalette.rosa,
                        title: "Scegli e rinomina la rosa",
                        description: "Il selettore “Rosa Giocatori” è disponibile in Rose, Partite, Allenamenti e Ranking. La scelta è condivisa tra le schede: ciascuna mostra i dati della rosa selezionata. Nella scheda Rose, il titolo della card riporta l’annata; usa “Rinomina Rosa Giocatori” per cambiarne il nome."
                    )
                    HelpRow(
                        iconName: "person.3.fill",
                        color: BoardPalette.rosa,
                        title: "Gestisci i giocatori",
                        description: "Tocca “Nuovo giocatore” per aggiungere un atleta alla rosa selezionata. Compila il terzo campo, “Identificativo”, SOLO in caso di omonimia: due giocatori con lo stesso nome e cognome nella stessa rosa. Usa un numero di maglia o un soprannome diverso per distinguerli. Se non ci sono omonimi, lascia il campo vuoto. Nome, cognome e identificativo uguali vengono bloccati come duplicati. L’identificativo è visibile anche nelle presenze, nelle convocazioni e nel ranking. Aggiungi gli omonimi singolarmente tramite “Nuovo giocatore”. Lo stesso nome può essere presente in rose diverse. Tocca un nome per modificarlo."
                    )
                    HelpRow(
                        iconName: "doc.on.clipboard",
                        color: BoardPalette.rosa,
                        title: "Importa una lista",
                        description: "Seleziona la rosa, poi da “Gestisci” scegli “Importa una lista”. Scrivi un giocatore per riga, ad esempio MARIO DI ROSSI: la prima parola è il nome, le successive sono il cognome. Usa solo lettere e un singolo spazio tra le parole, senza righe vuote. Se ci sono giocatori già presenti o ripetuti nella lista, un avviso blocca l’importazione: rimuovi i duplicati e riprova. Nessun giocatore viene importato."
                    )
                }

                Section("Partite") {
                    HelpRow(
                        iconName: "sportscourt.fill",
                        color: BoardPalette.partite,
                        title: "Organizza una partita",
                        description: "Seleziona la rosa e tocca “Nuova partita”: la partita appartiene a quella rosa. Nel dettaglio, “Rosa Giocatori” indica la rosa a cui appartiene. Aprila per scegliere tipo, data e ora. Indica se giochi in casa o fuori casa e il campo della trasferta."
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
                        description: "Seleziona la rosa e tocca “Nuovo allenamento”: la sessione appartiene a quella rosa. Aprila per impostare data, ora e note. Nel dettaglio, “Rosa Giocatori” indica la rosa della sessione."
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
                        description: "Seleziona la rosa, poi scegli “Allenamenti” o “Convocazioni” per ordinare i giocatori per presenze o convocazioni. Ogni riga mostra il conteggio e la percentuale sul totale degli eventi della rosa selezionata. Ogni rosa ha una classifica indipendente."
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
                        description: "Nella scheda Rose, scegli la rosa e apri “Gestisci” → “Elimina rosa”. Dopo la conferma vengono eliminati la rosa e tutti i suoi giocatori, allenamenti e partite. La rosa scompare da tutti i selettori; le altre rose rimangono intatte. L’operazione non può essere annullata. Se elimini l’ultima rosa, torna la schermata per crearne una nuova."
                    )
                    HelpRow(
                        iconName: "checkmark.shield.fill",
                        color: .blue,
                        title: "Salvataggio automatico",
                        description: "Rose, giocatori, partite e allenamenti vengono salvati e restano disponibili alla riapertura dell’app. Anche la scelta della rosa viene ricordata."
                    )
                }
            }
            .boardList(BoardPalette.rosa)
            .listStyle(.plain)
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
        DisclosureGroup {
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.bottom, 6)
        } label: {
            HStack(spacing: 12) {
                BoardIcon(symbol: iconName, color: color)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
        }
        .tint(color)
        .padding(18)
        .background(color.opacity(0.10).gradient, in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(color.opacity(0.18), lineWidth: 1)
        }
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

private struct HelpIntroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "book.closed.fill")
                .font(.largeTitle)
                .padding(14)
                .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 18))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text("La tua squadra,\nsempre organizzata.")
                    .font(.system(.title, design: .rounded, weight: .bold))
                Text("Dalla prima rosa alle convocazioni: tutto quello che serve per usare MisterBoard.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .fixedSize(horizontal: false, vertical: true)

            Label("Tocca un argomento per scoprire i dettagli", systemImage: "hand.tap")
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    BoardPalette.rosa.mix(with: .black, by: 0.35),
                    BoardPalette.rosa.mix(with: .black, by: 0.65)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 26)
        )
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 20, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    HelpView()
}

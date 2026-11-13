//
//  InfoView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss // Per chiudere la pagina modale

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Aggiunta dei nuovi prodotti")) {
                    HelpRow(iconName: "plus.circle.fill", color: .green, title: "Aggiungere un articolo", description: "Tocca il pulsante '+' per aggiungere nuovi prodotti alla lista spesa. Potrai scrivere il prodotto in modo rapido e semplice.")
                    HelpRow(iconName: "microphone.fill", color: .blue, title: "Dettatura dei prodotti", description: "Puoi anche dettare il nuovo prodotto da inserire e MySp€sa lo inserirà per te! Tocca il microfono e detta il tuo prodotto. Semplice e veloce! Per esempio dici: Pasta, o Pane o Pane integrale. Non preoccuparti di interrompere la registrazione perchè MySp€sa lo farà non appena avrai terminato di parlare.")
                    HelpRow(iconName: "camera.fill", color: .blue, title: "Scanner prodotti", description: "Puoi anche scannerizzare il nuovo prodotto con la fotocamera. MySp€sa lo inserirà per te dopo che avrai fatto tap sul nome del prodotto che stai inquadrando! Tocca la fotocamera e scannerizza il tuo prodotto. Semplice e veloce! Quando vedi i bordi colorati che circoscrivono il testo del prodotto, tocca e scatta! Troverai il prodotto in lista. Non preoccuparti di interrompere la fotocamera perché MySp€sa lo farà quando avrai terminato di scattare. Potrai farlo per la lista Spesa, ma potrai anche inserire i prodotti, direttamente nel carrello virtuale!")
                }
                
                Section(header: Text("Importi e Quantità nel Carrello")) {
                    HelpRow(iconName: "square.and.pencil", color: .white, title: "Inserire Quantità e Importi", description: "Una volta nel carrello, puoi inserire la quantità 📦 (nel caso di confezioni) e l'importo. Ogni volta che varierai la quantità, avrai il totale per quel prodotto, calcolato in automatico. Nel caso di frutta o verdura a peso, lascia quantità = 1 e scrivi l'importo che trovi sull'etichetta o sullo scontrino della bilancia.")
                    HelpRow(iconName: "eurosign.circle.fill", color: .white, title: "Scopri il totale da pagare", description: "Una volta indicati quantità e importi, tocca il pulsante '€' in 'Prodotti nel tuo carrello' e scopri quanto dovrai pagare alla cassa. Avrai un'importo totale e il dettaglio per categoria di prodotto.")
                }
                
                Section(header: Text("Trasferimento Prodotti")) {
                    HelpRow(iconName: "arrow.left.arrow.right", color: .white, title: "Spostare singoli articoli", description: "Scorri l'articolo verso destra (swipe leading) per spostarlo da 'Lista Spesa' a 'Carrello' e viceversa")
                    HelpRow(iconName: "truck.box", color: .white, title: "Riportare tutti gli articoli dal carrello alla lista", description: "Clicca sul 🚚 e riporti tutti gli articoli dal carrello alla lista.")
                }
                
                Section(header: Text("Ricerca dei prodotti")) {
                    HelpRow(iconName: "magnifyingglass.circle", color: .white, title: "Cerca prodotti e categorie", description: "Tocca il campo di ricerca in alto alla lista della spesa e comincia a cercare i prodotti inseriti nella lista spesa o nel carrello. Puoi cercare sia per prodotto sia per categoria, segli tu!")
                }
                
                Section(header: Text("Eliminazione dei prodotti")) {
                    HelpRow(iconName: "arrow.left.arrow.right", color: .red, title: "Eliminare un articolo", description: "Scorri l'articolo verso sinistra (swipe trailing) ed elimina.")
                    HelpRow(iconName: "trash.fill", color: .red, title: "Eliminare tutte le voci in Lista Spesa o Carrello", description: "Tocca il tasto 'Svuota Lista' o 'Svuota Carrello' ed eliminerai tutte le voci relative, in un colpo solo!")
                }
                
                Section(header: Text("Volantini pubblicitari")) {
                    HelpRow(iconName: "book.fill", color: .white, title: "Consulta i volantini dei principali Super Market", description: "Una volta nel tuo super mercato preferito, puoi consultare il volantino delle offerte e prendere nota dei prodotti e dei prezzi. Puoi copiare i nomi dei prodotti e inserirli nella tua lista spesa.")
                }
                
                Section(header: Text("Persistenza Dati")) {
                    HelpRow(iconName: "checkmark.shield.fill", color: .yellow, title: "Salvataggio Automatico", description: "MySp€sa esegue il salvataggio automatico dei tuoi progressi in tempo reale, sia quando inserisci i prodotti o digiti gli importi, sia quando sposti gli articoli. I dati della Lista Spesa e del Carrello sono permanenti. Potrai riprendere la tua spesa in qualsiasi momento, senza dover mai reinserire prodotti o importi, finché non sarai tu ad eliminarli manualmente.")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Guida e Informazioni")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Chiudi")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

// Una sub-view per rendere le righe del vademecum riutilizzabili e visive
struct HelpRow: View {
    let iconName: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconName)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.bold)
                Text(description)
                    .font(.system(size: 15,
                                 weight: .regular,
                                 design: .default))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// Anteprima per Xcode
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}

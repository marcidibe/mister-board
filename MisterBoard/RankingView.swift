//
//  RankingView.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

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
            VStack {
                Picker("Tipo Ranking", selection: $tipoRanking) {
                    Text("Allenamenti").tag(0)
                    Text("Convocazioni").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List(Array(giocatoriOrdinati.enumerated()), id: \.element.id) { index, giocatore in
                    let conteggio = tipoRanking == 0 ? giocatore.allenamentiPresenti.count : giocatore.partiteConvocate.count
                    let totale = tipoRanking == 0 ? allenamenti.count : partite.count
                    let percentuale = totale > 0 ? Int((Double(conteggio) / Double(totale)) * 100) : 0
                    
                    HStack {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                            .foregroundStyle(index < 3 ? .orange : .secondary)
                            .frame(width: 28, alignment: .leading)
                        
                        Text(giocatore.nomeCompleto)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(conteggio) / \(totale)")
                                .fontWeight(.semibold)
                            Text("\(percentuale)%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Ranking Squadra")
        }
    }
}

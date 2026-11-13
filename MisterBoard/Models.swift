//
//  Models.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import Foundation
import SwiftData

@Model
final class Giocatore {
    var nome: String
    var cognome: String
    
    // Relazioni inverse gestite automaticamente da SwiftData
    var partiteConvocate: [Partita] = []
    var allenamentiPresenti: [Allenamento] = []
    
    init(nome: String, cognome: String) {
        self.nome = nome
        self.cognome = cognome
    }
    
    var nomeCompleto: String {
        "\(cognome) \(nome)"
    }
}

@Model
final class Partita {
    var dataOra: Date
    var avversario: String // Opzionale: utile per distinguere le partite nello storico
    var inCasa: Bool = true
    var luogo: String = ""
    
    @Relationship(inverse: \Giocatore.partiteConvocate)
    var convocati: [Giocatore] = []
    
    init(dataOra: Date = .now, avversario: String = "Partita", inCasa: Bool = true, luogo: String = "") {
        self.dataOra = dataOra
        self.avversario = avversario
        self.inCasa = inCasa
        self.luogo = luogo
    }
}

@Model
final class Allenamento {
    var dataOra: Date
    var note: String
    
    @Relationship(inverse: \Giocatore.allenamentiPresenti)
    var presenti: [Giocatore] = []
    
    init(dataOra: Date = .now, note: String = "") {
        self.dataOra = dataOra
        self.note = note
    }
}

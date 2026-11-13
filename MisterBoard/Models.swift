//
//  Models.swift
//  MisterBoard
//
//  Created by Marcello Di Benedetto on 13/11/2026.
//

import Foundation
import SwiftData

enum TestoAnagrafico {
    // Valida tutta la lista prima di creare oggetti SwiftData.
    static func validaLista(_ testo: String) -> [(nome: String, cognome: String)]? {
        let lista = testo.uppercased()
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .newlines)
        guard !lista.isEmpty else { return nil }

        var giocatori: [(nome: String, cognome: String)] = []
        for riga in lista.components(separatedBy: "\n") {
            let parti = riga.split(separator: " ", omittingEmptySubsequences: false)
            guard parti.count == 2,
                  parti.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isLetter) }) else {
                return nil
            }
            giocatori.append((nome: String(parti[0]), cognome: String(parti[1])))
        }
        return giocatori
    }

    static func normalizza(_ testo: String) -> String {
        testo.uppercased().filter { carattere in
            carattere.isLetter || carattere == " "
        }
    }
}

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

enum TipoPartita: String {
    case torneo
    case amichevole
    case campionato

    var titolo: LocalizedStringResource {
        switch self {
        case .torneo: "TORNEO"
        case .amichevole: "AMICHEVOLE"
        case .campionato: "CAMPIONATO"
        }
    }
}

@Model
final class Partita {
    var dataOra: Date
    var avversario: String // Opzionale: utile per distinguere le partite nello storico
    var inCasa: Bool = true
    var luogo: String = ""
    private var tipoRawValue: String = "torneo"

    var tipo: TipoPartita {
        get { TipoPartita(rawValue: tipoRawValue) ?? .torneo }
        set { tipoRawValue = newValue.rawValue }
    }
    
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

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
            guard parti.count >= 2,
                  parti.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isLetter) }) else {
                return nil
            }
            // La prima parola è il nome; le successive formano il cognome composto.
            giocatori.append((nome: String(parti[0]), cognome: parti.dropFirst().joined(separator: " ")))
        }
        return giocatori
    }

    // Mantiene separati nome e cognome, ignorando maiuscole e spazi ripetuti.
    static func chiave(nome: String, cognome: String) -> [String] {
        [nome, cognome].map {
            $0.uppercased().split(whereSeparator: \.isWhitespace).joined(separator: " ")
        }
    }

    static func normalizza(_ testo: String) -> String {
        testo.uppercased().filter { carattere in
            carattere.isLetter || carattere == " "
        }
    }
}

@Model
final class Giocatore {
    // Opzionale per consentire la migrazione dei dati precedenti alle annate.
    var rosaID: UUID?

    var nome: String
    var cognome: String
    var identificativo: String? = nil
    
    // Relazioni inverse gestite automaticamente da SwiftData
    var partiteConvocate: [Partita] = []
    var allenamentiPresenti: [Allenamento] = []
    
    init(nome: String, cognome: String) {
        self.nome = nome
        self.cognome = cognome
    }
    
    var identificativoPulito: String {
        Self.normalizzaIdentificativo(identificativo ?? "")
    }

    static func normalizzaIdentificativo(_ testo: String) -> String {
        testo.uppercased().split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    var nomeCompleto: String {
        identificativoPulito.isEmpty ? "\(cognome) \(nome)" : "\(cognome) \(nome) · \(identificativoPulito)"
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
    // Opzionale per consentire la migrazione dei dati precedenti alle annate.
    var rosaID: UUID?

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
    // Opzionale per consentire la migrazione dei dati precedenti alle annate.
    var rosaID: UUID?

    var dataOra: Date
    var note: String
    
    @Relationship(inverse: \Giocatore.allenamentiPresenti)
    var presenti: [Giocatore] = []
    
    init(dataOra: Date = .now, note: String = "") {
        self.dataOra = dataOra
        self.note = note
    }
}

@Model
final class RosaAnnata {
    var id: UUID = UUID()
    var annata: String

    init(annata: String) {
        self.annata = annata
    }
}

enum GestioneRose {
    @MainActor
    static func elimina(id: UUID, in context: ModelContext) throws {
        // Conserva le modifiche precedenti prima di iniziare la cancellazione.
        try context.save()
        let rosaID: UUID? = id
        let rose = try context.fetch(FetchDescriptor<RosaAnnata>(predicate: #Predicate { $0.id == id }))
        let giocatori = try context.fetch(FetchDescriptor<Giocatore>(predicate: #Predicate { $0.rosaID == rosaID }))
        let partite = try context.fetch(FetchDescriptor<Partita>(predicate: #Predicate { $0.rosaID == rosaID }))
        let allenamenti = try context.fetch(FetchDescriptor<Allenamento>(predicate: #Predicate { $0.rosaID == rosaID }))
        for partita in partite { context.delete(partita) }
        for allenamento in allenamenti { context.delete(allenamento) }
        for giocatore in giocatori { context.delete(giocatore) }
        for rosa in rose { context.delete(rosa) }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

enum MigrazioneRose {
    // Eseguita prima di mostrare le sezioni: conserva anche eventi senza partecipanti.
    @MainActor
    static func prepara(in context: ModelContext) throws {
        let giocatori = try context.fetch(FetchDescriptor<Giocatore>(predicate: #Predicate { $0.rosaID == nil }))
        let partite = try context.fetch(FetchDescriptor<Partita>(predicate: #Predicate { $0.rosaID == nil }))
        let allenamenti = try context.fetch(FetchDescriptor<Allenamento>(predicate: #Predicate { $0.rosaID == nil }))
        let haDatiPrecedenti = !giocatori.isEmpty || !partite.isEmpty || !allenamenti.isEmpty
        guard haDatiPrecedenti else { return }

        let rosa = RosaAnnata(annata: haDatiPrecedenti ? "Rosa esistente" : "Prima rosa")
        context.insert(rosa)
        for giocatore in giocatori { giocatore.rosaID = rosa.id }
        for partita in partite { partita.rosaID = rosa.id }
        for allenamento in allenamenti { allenamento.rosaID = rosa.id }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

import SwiftUI
import SwiftData

private struct BenvenutoRosaView: View {
    let creaRosa: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Label("IL TUO PROSSIMO INIZIO", systemImage: "sparkles")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.white.opacity(0.85))

                Image(systemName: "person.3.fill")
                    .font(.system(size: 48, weight: .medium))
                    .padding(24)
                    .background(.white.opacity(0.13), in: RoundedRectangle(cornerRadius: 28))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Una squadra.\nTante possibilità.")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Ogni grande stagione comincia dalla tua rosa.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .foregroundStyle(.white)
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(LinearGradient(
                        colors: [Color(red: 0.12, green: 0.36, blue: 0.72),
                                 Color(red: 0.07, green: 0.14, blue: 0.36)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .stroke(.white.opacity(0.08), lineWidth: 32)
                            .frame(width: 180, height: 180)
                            .offset(x: 65, y: -60)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 32))
            }
            .shadow(color: BoardPalette.rosa.opacity(0.16), radius: 18, y: 10)

            VStack(alignment: .leading, spacing: 20) {
                Text("Tutto parte da un’annata")
                    .font(.title3.weight(.bold))

                Label("Giocatori sempre organizzati", systemImage: "person.3")
                Label("Presenze e convocazioni a portata di mano", systemImage: "checkmark.circle")
                Label("Un ranking dedicato a ogni rosa", systemImage: "chart.bar")
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: creaRosa) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                    Text("Crea la prima rosa")
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .padding(18)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(
                    Color(red: 0.12, green: 0.32, blue: 0.67).gradient,
                    in: RoundedRectangle(cornerRadius: 20)
                )
            }
            .buttonStyle(.plain)

            Text("Scegli l’annata, poi aggiungi i tuoi giocatori.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
    }
}

struct SelettoreAnnataView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RosaAnnata.annata) private var rose: [RosaAnnata]
    @Binding var selezione: UUID
    let consenteGestione: Bool

    @State private var mostraEditor = false
    @State private var creaNuova = false
    @State private var annata = ""
    @State private var errore: String?

    private var annataPulita: String {
        annata.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var nomeValido: Bool {
        !annataPulita.isEmpty && !rose.contains {
            (creaNuova || $0.id != selezione) &&
            $0.annata.compare(annataPulita, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
    }

    var body: some View {
        Section {
            if rose.isEmpty && consenteGestione {
                BenvenutoRosaView {
                    creaNuova = true
                    annata = ""
                    mostraEditor = true
                }
            }
            if !rose.isEmpty {
                Picker("Annata", selection: $selezione) {
                    ForEach(rose) { rosa in
                        Text(rosa.annata).tag(rosa.id)
                    }
                }
            }
            if consenteGestione && !rose.isEmpty {
                Button("Aggiungi una Nuova Rosa", systemImage: "plus") {
                    creaNuova = true
                    annata = ""
                    mostraEditor = true
                }
                if !rose.isEmpty {
                    Button("Rinomina annata", systemImage: "pencil") {
                        creaNuova = false
                        annata = rose.first(where: { $0.id == selezione })?.annata ?? ""
                        mostraEditor = true
                    }
                }
            }
        }
        .alert(creaNuova ? "Nuova rosa" : "Rinomina annata", isPresented: $mostraEditor) {
            TextField("Annata (es. 2014 o 2026/2027)", text: $annata)
            Button("Annulla", role: .cancel) {}
            Button("Salva") { salva() }
                .disabled(!nomeValido)
        } message: {
            Text("Scegli un’annata univoca per questa rosa. Giocatori, partite, allenamenti e ranking saranno gestiti separatamente.")
        }
        .alert("Salvataggio non riuscito", isPresented: Binding(
            get: { errore != nil },
            set: { if !$0 { errore = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errore ?? "")
        }
    }

    private func salva() {
        guard nomeValido else { return }
        // Salva prima le eventuali modifiche correnti alle altre sezioni.
        do {
            try modelContext.save()
        } catch {
            errore = error.localizedDescription
            return
        }
        let rosa: RosaAnnata
        if creaNuova {
            rosa = RosaAnnata(annata: annataPulita)
            modelContext.insert(rosa)
        } else {
            guard let esistente = rose.first(where: { $0.id == selezione }) else { return }
            rosa = esistente
            rosa.annata = annataPulita
        }
        do {
            try modelContext.save()
            selezione = rosa.id
        } catch {
            modelContext.rollback()
            errore = error.localizedDescription
        }
    }
}

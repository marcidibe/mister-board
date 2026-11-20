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

                    GuidaRapidaRosaView()
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

            SintesiRosaView()

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
        }
        .padding(.vertical, 12)
    }
}

private struct SintesiRosaView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tutto parte da un’annata")
                .font(.title3.weight(.bold))

            Label("Giocatori sempre organizzati", systemImage: "person.3")
            Label("Presenze e convocazioni a portata di mano", systemImage: "checkmark.circle")
            Label("Un ranking dedicato a ogni rosa", systemImage: "chart.bar")
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GuidaRapidaRosaView: View {
    @State private var mostraGuida = false

    var body: some View {
        DisclosureGroup(isExpanded: $mostraGuida) {
            VStack(alignment: .leading, spacing: 20) {
                PassaggioGuidaRosaView(
                    numero: 1,
                    titolo: "Crea un’annata",
                    descrizione: "Dai un nome alla rosa, ad esempio 2013 o 2026/2027."
                )
                PassaggioGuidaRosaView(
                    numero: 2,
                    titolo: "Aggiungi i giocatori",
                    descrizione: "Inseriscili singolarmente oppure importa una lista dal menu Gestisci."
                )
                PassaggioGuidaRosaView(
                    numero: 3,
                    titolo: "Organizza la squadra",
                    descrizione: "Registra presenze, prepara convocazioni e consulta il ranking della tua rosa."
                )
                Text("Troverai la guida completa nella scheda Info.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.top, 18)
            .padding(.bottom, 4)
        } label: {
            Label("Come funziona", systemImage: "questionmark.circle")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.78, green: 0.9, blue: 1))
                .padding(.vertical, 6)
        }
        .tint(Color(red: 0.78, green: 0.9, blue: 1))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.12), .white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }
}

private struct PassaggioGuidaRosaView: View {
    let numero: Int
    let titolo: LocalizedStringResource
    let descrizione: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(numero, format: .number)
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundStyle(Color(red: 0.78, green: 0.9, blue: 1))
                .padding(10)
                .background(.white.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(titolo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(descrizione)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
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
                Picker("Rosa Giocatori", selection: $selezione) {
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
                    Button("Rinomina Rosa Giocatori", systemImage: "pencil") {
                        creaNuova = false
                        annata = rose.first(where: { $0.id == selezione })?.annata ?? ""
                        mostraEditor = true
                    }
                }
            }
        }
        .alert(creaNuova ? "Nuova rosa" : "Rinomina Rosa Giocatori", isPresented: $mostraEditor) {
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

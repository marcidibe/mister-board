import SwiftUI

enum BoardPalette {
    static let rosa = Color.blue
    static let partite = Color.orange
    static let allenamenti = Color.green
    static let ranking = Color.purple
}

struct BoardSummaryCard: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let symbol: String
    let color: Color
    let count: Int

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: symbol)
                    .font(.headline)
                Text(count, format: .number)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text(subtitle)
                    .font(.subheadline)
            }
            Spacer(minLength: 0)
            Image(systemName: symbol)
                .font(.largeTitle)
                .padding(14)
                .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 20))
                .accessibilityHidden(true)
        }
        .foregroundStyle(.white)
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [color.mix(with: .black, by: 0.35), color.mix(with: .black, by: 0.55)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26)
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

struct BoardDateTimePicker: View {
    @Binding var selection: Date
    @State private var mostraSelettore = false

    var body: some View {
        Button {
            mostraSelettore = true
        } label: {
            HStack {
                Text("Data e Ora")
                    .foregroundStyle(.primary)
                Spacer()
                Text(selection.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(Locale(identifier: "it_IT"))))
                    .multilineTextAlignment(.trailing)
            }
        }
        .sheet(isPresented: $mostraSelettore) {
            NavigationStack {
                ScrollView {
                    DatePicker("Data e Ora", selection: $selection, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.wheel)
                        .environment(\.locale, Locale(identifier: "it_IT"))
                        .labelsHidden()
                        .padding()
                }
                .navigationTitle("Data e Ora")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fine") {
                            mostraSelettore = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

struct BoardIcon: View {
    let symbol: String
    let color: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.title3.weight(.semibold))
            .foregroundStyle(color)
            .padding(12)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            .accessibilityHidden(true)
    }
}

private struct BoardCardRow: ViewModifier {
    let color: Color
    let compact: Bool

    func body(content: Content) -> some View {
        content
            .padding(.vertical, compact ? 2 : 10)
            .listRowInsets(compact ? EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12) : nil)
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: compact ? 14 : 22)
                    .fill(color.opacity(0.10).gradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: compact ? 14 : 22)
                            .strokeBorder(color.opacity(0.18), lineWidth: 1)
                    }
                    .padding(.vertical, 4)
            )
    }
}

extension View {
    func boardCardRow(_ color: Color, compact: Bool = false) -> some View {
        modifier(BoardCardRow(color: color, compact: compact))
    }

    func boardList(_ color: Color) -> some View {
        listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(color.opacity(0.035).ignoresSafeArea())
            .tint(color)
    }
}

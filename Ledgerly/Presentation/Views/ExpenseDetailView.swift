import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense

    var categoryColor: Color {
        switch expense.category {
        case "Food":    return .blue
        case "Transport": return .orange
        case "Bill":      return .purple
        default:          return .gray
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.pink.gradient)
                        .frame(height: 180)

                    VStack(alignment: .center, spacing: 4) {
                        Text("total_amount")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(expense.amount, format: .number.precision(.fractionLength(2)))
                                .font(.system(size: 44, weight: .medium))
                                .foregroundStyle(.white)
                            Text(" €")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.bottom, 28)
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(expense.title)
                            .font(.title3.weight(.medium))
                        Spacer()
                        Text(expense.category)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(categoryColor.opacity(0.15))
                            .foregroundStyle(categoryColor)
                            .clipShape(Capsule())
                    }
                    .padding()

                    Divider()

                    VStack(spacing: 0) {
                        DetailRow(label: "expense_date") {
                            Text(expense.date.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                        }

                        Divider().padding(.leading)
                        
                        DetailRow(label: "section_category") {
                            Text(expense.category)
                                .font(.subheadline)
                        }
                        
                        
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: -16)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let content: AnyView

    init(label: String, @ViewBuilder content: () -> some View) { //because we want to use a view builder for the content but we also want to store it in a property
        self.label = label
        self.content = AnyView(content())
    }

    var body: some View {
        HStack {
            Text(LocalizedStringKey(label))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            content
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

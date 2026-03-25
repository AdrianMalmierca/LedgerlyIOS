import SwiftUI

struct ExpenseDetailView: View {
    
    let expense: Expense
    
    var body: some View {
        VStack(spacing: 20) {
            Text(expense.title).font(.largeTitle)
            Text("\(expense.amount, specifier: "%.2f") €").font(.title)
            Text(expense.category).foregroundColor(.secondary)
            Text(expense.date.formatted())
        }
        .padding()
    }
}

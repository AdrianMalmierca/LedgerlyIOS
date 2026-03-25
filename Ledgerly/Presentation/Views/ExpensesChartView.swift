import SwiftUI
import Charts

struct ExpensesChartView: View {
    let expenses: [Expense]

    var body: some View {
        Chart {
            ForEach(expenses) { expense in
                BarMark(
                    x: .value("Category", expense.category),
                    y: .value("Amount", expense.amount)
                )
                .foregroundStyle(by: .value("Category", expense.category))
            }
        }
        .chartXAxisLabel("Category")
        .chartYAxisLabel("Amount (€)")
        .frame(height: 250)
    }
}


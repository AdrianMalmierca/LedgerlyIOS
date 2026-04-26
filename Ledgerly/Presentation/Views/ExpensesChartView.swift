import SwiftUI
import Charts

struct ExpensesChartView: View {
    let expenses: [Expense]

    var body: some View {
        Chart {
            ForEach(expenses) { expense in
                BarMark(
                    x: .value("section_category", expense.category),
                    y: .value("section_amount", expense.amount)
                )
                .foregroundStyle(by: .value("section_category", expense.category))
            }
        }
        .chartXAxisLabel("section_category")
        .chartYAxisLabel("section_amount")
        .frame(height: 250)
    }
}

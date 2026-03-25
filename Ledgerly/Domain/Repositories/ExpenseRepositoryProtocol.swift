import Foundation

protocol ExpenseRepositoryProtocol {
    func fetchLocalExpenses() -> [Expense]
    func addExpense(_ expense: Expense)
    func syncWithBackend() async throws
    func deleteExpense(_ expense: Expense)
}

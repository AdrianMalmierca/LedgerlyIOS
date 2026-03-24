//
//  ExpenseListViewModel.swift
//  Ledgerly
//
//  Created by Adrián on 16/2/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor //ensure that all properties and methods are executed on the main thread
final class ExpenseListViewModel: ObservableObject {
    
    // MARK: - Inputs
    //@Published -> each change to these properties will trigger the view to update
    @Published var searchText: String = ""
    @Published var selectedCategory: String? = nil
    
    // MARK: - Outputs
    //with private(set) we can onnly modify these properties within the view model, but the view can read them and react to changes
    @Published private(set) var expenses: [Expense] = []
    @Published private(set) var filteredExpenses: [Expense] = []
    
    private let repository: ExpenseRepositoryProtocol
    private var cancellables = Set<AnyCancellable>() //to store our Combine subscriptions and cancel them when the view model is deallocated
    
    init(repository: ExpenseRepositoryProtocol = ExpenseRepository()) {
        self.repository = repository
        
        loadExpenses()
        setupBindings()
    }
    
    // MARK: - Carga de gastos
    func loadExpenses() {
        expenses = repository.fetchLocalExpenses()
        filteredExpenses = expenses
    }
    
    func addExpense(title: String, amount: Double, category: String) {
        let expense = Expense(
            id: UUID(),
            title: title,
            amount: amount,
            date: Date(),
            category: category
        )
        repository.addExpense(expense)
        loadExpenses()
    }
    
    func deleteExpense(_ expense: Expense) {
        repository.deleteExpense(expense)
        loadExpenses()
    }
    
    func sync() async {
        try? await repository.syncWithBackend()
        loadExpenses()
    }
    
    // MARK: - Combine bindings
    private func setupBindings() {
        //Reactive filter: category + search
        Publishers.CombineLatest($searchText, $selectedCategory)
            .map { [weak self] (query, category) -> [Expense] in //Transforms the combination into a new filtered list. [weak self] prevents hold cycles
                guard let self = self else { return [] }
                return self.expenses.filter { expense in
                    let matchesCategory = category == nil || expense.category == category
                    let matchesSearch = query.isEmpty || expense.title.lowercased().contains(query.lowercased())
                    return matchesCategory && matchesSearch
                }
            }
            .receive(on: DispatchQueue.main) //Ensure that the final allocation occurs on the main thread.
            .assign(to: \.filteredExpenses, on: self) //Every time the search or category changes: recalculates and automatically assigns to filteredExpenses
            .store(in: &cancellables) //without this line, the subscription would be immediately cancelled after being created, so we store it in the cancellables set to keep it alive as long as the view model exists
    }
}

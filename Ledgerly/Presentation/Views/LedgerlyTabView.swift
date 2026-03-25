import SwiftUI

struct LedgerlyTabView: View {
    @StateObject private var viewModel = ExpenseListViewModel()
    @State private var showingAdd = false
    
    private let categories = ["Food", "Transport", "Bills", "Other"]
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() //solid background
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            //Expense list
            NavigationStack {
                VStack {
                    TextField("Buscar gasto...", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    CategoriesGridView(categories: categories, selectedCategory: $viewModel.selectedCategory)
                        .padding(.vertical, 5)
                    
                    List {
                        ForEach(viewModel.filteredExpenses) { expense in
                            NavigationLink {
                                ExpenseDetailView(expense: expense)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(expense.title)
                                        .font(.headline)
                                    Text("\(expense.amount, specifier: "%.2f") €")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let expense = viewModel.filteredExpenses[index]
                                viewModel.deleteExpense(expense)
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 50) } //avoid that the last item of the list is hidden behind the tab bar
                }
                .navigationTitle("Ledgerly")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAdd = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Sync") {
                            Task {
                                await viewModel.sync()
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAdd) {
                    AddExpenseView { title, amount, category in
                        viewModel.addExpense(title: title, amount: amount, category: category)
                    }
                }
            }
            .tabItem {
                Label("Gastos", systemImage: "list.bullet")
            }

            //Expense chart
            NavigationStack {
                ExpensesChartView(expenses: viewModel.expenses)
                    .navigationTitle("Gráfico")
            }
            .tabItem {
                Label("Gráfico", systemImage: "chart.bar")
            }
        }
    }
}

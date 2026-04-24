import Foundation
import CoreData

@MainActor
final class ExpenseRepository: ExpenseRepositoryProtocol {
    
    private let context = CoreDataStack.shared.context
    private let network: NetworkServiceProtocol
    private let auth: AuthService
    
    init(network: NetworkServiceProtocol? = nil, auth: AuthService = .shared) {
        self.network = network ?? NetworkService()
        self.auth = auth
    }
    
    private var currentUserId: String {
        auth.userId ?? ""
    }
    
    func fetchLocalExpenses() -> [Expense] {
        //request for obtaining all ExpenseEntity from the database
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        
        do {
            let entities = try context.fetch(request)
            //you map those entities from ExpenseEntity to Extense and return the array of expenses
            return entities.map {
                Expense(
                    id: $0.id ?? UUID(),
                    title: $0.title ?? "",
                    amount: $0.amount,
                    date: $0.date ?? Date(),
                    category: $0.category ?? "Other",
                    userId: $0.userId ?? ""
                )
            }
        } catch { //if there's an error during fetching, you return an empty array
            return []
        }
    }
    
    func insertExpense(_ expense: Expense) { //build the object to be stored in the database
        //you create a new ExpenseEntity in the context and set its properties
        let entity = ExpenseEntity(context: context)
        entity.id = expense.id
        entity.title = expense.title
        entity.amount = expense.amount
        entity.date = expense.date
        entity.category = expense.category
        entity.userId = expense.userId
    }
    
    func addExpense(_ expense: Expense) {
        insertExpense(expense)
        try? context.save()
    }
    
    func deleteExpense(_ expense: Expense) {
        //you create a fetch request to find the ExpenseEntity with the same id as the expense you want to delete
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        
        //you set a predicate to filter the entities by id
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", expense.id as CVarArg, currentUserId) //CVarArg because the id is UUID type

        //you execute the fetch request, if you find the entity, you delete it from the context and save the changes
        if let entities = try? context.fetch(request), let entityToDelete = entities.first {
            context.delete(entityToDelete)
            try? context.save()
        }
    }
    
    func syncWithBackend() async throws {
        let remoteExpenses = try await network.fetchExpenses()
        
        for expense in remoteExpenses {
            //check if already exists
            let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@ AND userId == %@", expense.id as CVarArg, currentUserId)
            
            //limit to 1 result since we only care if it exists or not
            request.fetchLimit = 1
            
            //fetch the existing entities with the same id
            let existing = try context.fetch(request)
            if existing.isEmpty {
                let withUser = Expense(
                    id: expense.id,
                    title: expense.title,
                    amount: expense.amount,
                    date: expense.date,
                    category: expense.category,
                    userId: currentUserId
                )
                addExpense(withUser)  // ← withUser, no expense
            }
        }
        //you save the context
        try context.save()
    }

}

import CoreData

final class CoreDataStack { //this class is responsible for setting up and managing the Core Data stack, which includes loading the model, creating the persistent container, and providing access to the context for performing database operations.
    
    //the instance of the stack, singleton pattern
    static let shared = CoreDataStack()
    
    //loads the model and the db
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "LedgerlyModel")//load the model, the name must match the .xcdatamodeld file
        
        //load the persistent stores(db), if there's an error we crash the app because we can't continue without a database
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed: \(error)")
            }
        }
    }
    
    //we expose the context as a computed property for easy access
    var context: NSManagedObjectContext {
        container.viewContext
    }
}

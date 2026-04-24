import Foundation

//any class that implements this protocol must provide these two methods, one for fetching expenses and another for sending an expense to the backend
protocol NetworkServiceProtocol {
    func fetchExpenses() async throws -> [Expense]
    func sendExpense(_ expense: Expense) async throws
}

final class NetworkService: NetworkServiceProtocol {
    
    //is not a real backend, but a public API that returns a list of posts in JSON format
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
    
    func fetchExpenses() async throws -> [Expense] {
        let url = baseURL.appendingPathComponent("posts")
        
        //we need the information so we ignore the response
        let (data, _) = try await URLSession.shared.data(from: url) //petición get
        
        //transform from JSON to an array of PostDTO
        let decoded = try JSONDecoder().decode([PostDTO].self, from: data)
        
        //only take the first 20 posts to create expenses, since the API returns 100 posts
        return decoded.prefix(20).map {
            //create an Expense for each PostDTO, using the title from the post and random values for the other properties
            Expense(
                id: UUID(),
                title: $0.title,
                amount: Double.random(in: 5...100),
                date: Date(),
                category: "Other",
                userId: ""
            )
        }
    }
    
    func sendExpense(_ expense: Expense) async throws {
        let url = baseURL.appendingPathComponent("posts")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = try JSONEncoder().encode(expense)
        
        //we're not interested in the response, we just want to send the data, so we ignore it
        _ = try await URLSession.shared.data(for: request)
    }
}

private struct PostDTO: Decodable {
    //only the title is relevant for our example, but we could include other properties if needed
    let title: String
}

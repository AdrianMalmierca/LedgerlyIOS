import SwiftUI
import Lottie

struct AddExpenseView: View {
    
    //This view is a sheet so we need to close it after saving the expense. Thats why we need the dismiss environment variable
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var amount = ""
    @State private var category = "Other"
    @State private var showAnimation = false
    
    let categories = ["Food", "Transport", "Bills", "Other"]
    let onSave: (String, Double, String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("section_details") {
                    TextField("field_title", text: $title)
                    TextField("field_amount", text: $amount).keyboardType(.decimalPad)
                }
                
                Section("section_category") {
                    Picker("picker_category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }.pickerStyle(.menu) // could be .segmented or .wheel depending the preference
                }
            }.navigationTitle("new_expense_title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("save_button") {
                        if let value = Double(amount) {
                            onSave(title, value, category)
                            showAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                dismiss()
                            }
                        }
                    }.disabled(title.isEmpty || amount.isEmpty) //avoid saving an expense without title or amount
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("close_button") {
                        dismiss()
                    }
                }
            }.sheet(isPresented: $showAnimation) {
                LottieView(name: "success")
                    .frame(width: 200, height: 200)
            }
        }
    }
}

import SwiftUI

struct CategoriesGridView: View {
    let categories: [String]
    
    //to modify from LedgerlyTabView
    @Binding var selectedCategory: String?

    var body: some View {
        GeometryReader { geo in //cause we need that the layout depends about the avaiable space
            let width = geo.size.width
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            if selectedCategory == category {
                                selectedCategory = nil //deselect if already selected
                            } else {
                                selectedCategory = category
                            }
                        } label: {
                            Text(category)
                                .padding(10)
                                .background(selectedCategory == category ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .black)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(width: width, alignment: .center)
            }
        }
        .frame(height: 60)
    }
}



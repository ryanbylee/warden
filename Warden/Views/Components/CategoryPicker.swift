//
//  CategoryPicker.swift
//  Warden
//

import SwiftUI
import SwiftData

struct CategoryPicker: View {
    @Binding var selection: Category?
    let categories: [Category]
    var includeAllOption: Bool = false

    var body: some View {
        Picker("Category", selection: $selection) {
            if includeAllOption {
                Text("All Categories").tag(Optional<Category>(nil))
            }
            ForEach(categories) { category in
                Label(category.name, systemImage: category.systemIcon)
                    .tag(Optional(category))
            }
        }
        .pickerStyle(.menu)
    }
}

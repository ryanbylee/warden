//
//  AddCategoryView.swift
//  Warden
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, String) -> Void

    @State private var name: String = ""
    @State private var selectedIcon: String = "folder"

    let iconOptions = [
        "folder", "star", "heart", "tag", "cart", "cup.and.saucer",
        "airplane", "tram", "bicycle", "dumbbell", "book", "music.note",
        "gamecontroller", "theatermasks", "pawprint", "leaf", "gift",
        "wrench.and.screwdriver", "hammer", "paintbrush", "camera", "film",
        "graduationcap", "briefcase", "building.2", "house.lodge"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(selectedIcon == icon ? Color.accentColor : .secondary)
                                    .background(
                                        Group {
                                            if selectedIcon == icon {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .glassEffect(.regular.tint(.accentColor))
                                            }
                                        }
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name.trimmingCharacters(in: .whitespaces), selectedIcon)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .containerBackground(.clear, for: .navigation)
    }
}

#Preview {
    AddCategoryView { _, _ in }
}

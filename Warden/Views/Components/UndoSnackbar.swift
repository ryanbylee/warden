//
//  UndoSnackbar.swift
//  Warden
//

import SwiftUI

struct UndoState {
    let message: String
    let onUndo: () -> Void
}

struct UndoSnackbar: View {
    @Binding var undoState: UndoState?

    var body: some View {
        if let state = undoState {
            HStack(spacing: 12) {
                Text(state.message)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Button("Undo") {
                    state.onUndo()
                    withAnimation(.spring(duration: 0.3)) {
                        undoState = nil
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: Capsule())
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .task(id: state.message) {
                try? await Task.sleep(for: .seconds(4))
                withAnimation(.spring(duration: 0.3)) {
                    undoState = nil
                }
            }
        }
    }
}

//
//  MonthPickerView.swift
//  Warden
//

import SwiftUI

struct MonthPickerView: View {
    let label: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        GlassEffectContainer {
            HStack {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }
                .glassEffect(.regular.interactive(), in: .circle)

                Spacer()

                Text(label)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    MonthPickerView(label: "March 2026", onPrevious: {}, onNext: {})
        .padding()
}

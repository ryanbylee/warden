//
//  ProgressBarView.swift
//  Warden
//

import SwiftUI

struct ProgressBarView: View {
    let value: Double   // spent
    let total: Double   // budget limit
    var showPercentage: Bool = true

    private var ratio: Double {
        guard total > 0 else { return 0 }
        return min(value / total, 1.0)
    }

    private var isOver: Bool { value > total }

    private var barColor: Color {
        let pct = total > 0 ? value / total : 0
        if pct >= 1.0 { return .red }
        if pct >= 0.8 { return .orange }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                        .frame(height: 10)
                    Capsule()
                        .fill(barColor)
                        .frame(width: geo.size.width * ratio, height: 10)
                        .animation(.spring(duration: 0.4), value: ratio)
                }
            }
            .frame(height: 10)

            if showPercentage {
                HStack {
                    Text(value, format: .currency(code: "USD"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if total > 0 {
                        Text("\(Int(min(value / total * 100, 999)))%")
                            .font(.caption2)
                            .foregroundStyle(isOver ? .red : .secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressBarView(value: 300, total: 500)
        ProgressBarView(value: 420, total: 500)
        ProgressBarView(value: 550, total: 500)
    }
    .padding()
}

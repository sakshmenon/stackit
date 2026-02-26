//
//  DailyProgressView.swift
//  stackit
//
//  Daily completion progress for the main screen (PRD FR-10, NFR-1 lightweight).
//

import SwiftUI

/// Shows daily progress: completed count, total count, and a simple progress indicator.
struct DailyProgressView: View {
    let progress: DailyProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Today")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(progress.completedCount) / \(progress.totalCount)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.gray))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor)
                        .frame(width: max(0, geo.size.width * progress.completionRate))
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    DailyProgressView(progress: DailyProgress(completedCount: 3, totalCount: 8))
        .padding()
}

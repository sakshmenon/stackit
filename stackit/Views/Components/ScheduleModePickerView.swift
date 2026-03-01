//
//  ScheduleModePickerView.swift
//  stackit
//
//  Compact horizontal picker for the five task-ordering modes (queueing.py).
//

import SwiftUI

/// A horizontally scrollable row of mode chips. The active chip is filled;
/// inactive chips are outlined. Tapping a chip calls `onSelect`.
struct ScheduleModePickerView: View {
    let selectedMode: ScheduleMode
    var onSelect: (ScheduleMode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Queue mode")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ScheduleMode.allCases) { mode in
                        ModeChip(mode: mode, isSelected: mode == selectedMode) {
                            onSelect(mode)
                        }
                    }
                }
                .padding(.horizontal, 1)   // prevent clip on shadows
            }
        }
    }
}

// MARK: - Mode Chip

private struct ModeChip: View {
    let mode: ScheduleMode
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: mode.systemImage)
                    .font(.caption.weight(.semibold))
                Text(mode.displayName)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mode.displayName): \(mode.subtitle)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var background: Color {
        isSelected ? Color.accentColor : Color.secondary.opacity(0.08)
    }

    private var foreground: Color {
        isSelected ? .white : .primary
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var mode = ScheduleMode.priority
    return VStack(spacing: 20) {
        ScheduleModePickerView(selectedMode: mode) { mode = $0 }
        Text("Active: \(mode.displayName) — \(mode.subtitle)")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
}

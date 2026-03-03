//
//  DemoRootView.swift
//  Dispatch
//
//  Self-contained demo container: provides its own in-memory ScheduleStore and
//  BurstScheduler, starts the DemoCoordinator, and overlays the caption banner
//  and confetti when all tasks are done.
//

import SwiftUI

struct DemoRootView: View {
    var onExit: () -> Void

    @StateObject private var scheduleStore = ScheduleStore(repository: InMemoryScheduleItemRepository())
    @StateObject private var burstScheduler = BurstScheduler()
    @StateObject private var coordinator = DemoCoordinator()

    var body: some View {
        ZStack(alignment: .top) {
            // Main app UI driven by the demo coordinator
            RootContainerView()
                .environmentObject(scheduleStore)
                .environmentObject(burstScheduler)

            // Caption banner — describes what the demo is currently doing
            if !coordinator.caption.isEmpty {
                captionBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 56)
                    .zIndex(2)
            }

            // Confetti overlay
            if coordinator.showConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .zIndex(3)
            }

            // Exit button — always accessible at top-right
            exitButton
                .zIndex(4)
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.caption)
        .animation(.easeInOut(duration: 0.4), value: coordinator.showConfetti)
        .onAppear {
            coordinator.start(store: scheduleStore, scheduler: burstScheduler)
        }
        .onDisappear {
            coordinator.stop()
        }
    }

    // MARK: - Sub-views

    private var captionBanner: some View {
        Text(coordinator.caption)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }

    private var exitButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    coordinator.stop()
                    onExit()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .padding(11)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 36)
            }
        }
    }
}

#Preview {
    DemoRootView(onExit: {})
}

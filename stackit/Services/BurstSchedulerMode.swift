//
//  BurstSchedulerMode.swift
//  stackit
//
//  Preemptive vs non-preemptive scheduling modes (driver.py:29-60).
//

import Foundation

/// Time-based scheduling behaviour — orthogonal to queue ordering (ScheduleMode).
/// `.off` disables the burst timer entirely.
enum BurstSchedulerMode: String, CaseIterable, Identifiable, Codable {
    case off           = "off"
    case preemptive    = "preemptive"
    case nonPreemptive = "non_preemptive"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .off:           return "Off"
        case .preemptive:    return "Preemptive"
        case .nonPreemptive: return "Non-Preemptive"
        }
    }

    /// Short description shown in settings and the picker.
    var subtitle: String {
        switch self {
        case .off:           return "No time-based scheduling"
        case .preemptive:    return "Unfinished tasks move to back of queue"
        case .nonPreemptive: return "Stay on task until you confirm it done"
        }
    }

    var systemImage: String {
        switch self {
        case .off:           return "pause.circle"
        case .preemptive:    return "arrow.counterclockwise.circle"
        case .nonPreemptive: return "lock.circle"
        }
    }
}

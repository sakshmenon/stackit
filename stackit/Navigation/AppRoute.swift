//
//  AppRoute.swift
//  stackit
//
//  Type-safe navigation destinations (PROJECT_TIMELINE Day 1 – navigation scaffolding).
//

import Foundation

/// Destinations in the main navigation stack. Add cases as new screens are built.
enum AppRoute: Hashable {
    case settings
    case taskDetail(TaskItem)
    case addTask
}

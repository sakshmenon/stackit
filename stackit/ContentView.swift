//
//  ContentView.swift
//  stackit
//
//  Root content: main daily view (PRD main page architecture).
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainDailyView(
            currentTask: nil,
            progress: .empty
        )
    }
}

#Preview {
    ContentView()
}

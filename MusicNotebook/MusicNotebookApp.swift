//
//  MusicNotebookApp.swift
//  MusicNotebook
//

import SwiftUI

@main
struct MusicNotebookApp: App {
    @State private var store = NotebookStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}

//
//  MusicNotebookApp.swift
//  MusicNotebook
//

import SwiftUI

@main
struct MusicNotebookApp: App {
    @State private var library = NotebookLibrary()

    var body: some Scene {
        WindowGroup {
            NotebookListView()
                .environment(library)
        }
    }
}

//
//  ContentView.swift
//  MusicNotebook
//

import SwiftUI
import PencilKit

private let pageSize = CGSize(width: 1000, height: 1400)

struct ContentView: View {
    @Environment(NotebookStore.self) private var store

    var body: some View {
        NavigationStack {
            DrawingCanvasView(
                drawing: Binding(
                    get: { store.currentPage.drawing },
                    set: { newValue in
                        store.currentPage.drawing = newValue
                        store.save()
                    }
                ),
                pageSize: pageSize
            )
            .id(store.currentPage.id)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Music Notebook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        store.goToPreviousPage()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(store.currentPageIndex == 0)

                    Text("\(store.currentPageIndex + 1) / \(store.pages.count)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)

                    Button {
                        store.goToNextPage()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(store.currentPageIndex == store.pages.count - 1)
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        store.addPage()
                    } label: {
                        Label("Add Page", systemImage: "plus.square.on.square")
                    }

                    Button(role: .destructive) {
                        store.deleteCurrentPage()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(store.pages.count <= 1)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(NotebookStore())
}

//
//  NotebookListView.swift
//  MusicNotebook
//

import SwiftUI

struct NotebookListView: View {
    @Environment(NotebookLibrary.self) private var library
    @State private var isPresentingNewNotebookAlert = false
    @State private var newNotebookName = ""
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if library.notebooks.isEmpty {
                    ContentUnavailableView(
                        "노트북이 없습니다",
                        systemImage: "music.note.list",
                        description: Text("오른쪽 위 + 버튼을 눌러 새 노트북을 만들어보세요.")
                    )
                } else {
                    List {
                        ForEach(library.notebooks) { notebook in
                            NavigationLink(value: notebook.id) {
                                NotebookRow(notebook: notebook)
                            }
                        }
                        .onDelete(perform: deleteNotebooks)
                    }
                }
            }
            .navigationTitle("Music Notebook")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        newNotebookName = ""
                        isPresentingNewNotebookAlert = true
                    } label: {
                        Label("새 노트북", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                NotebookEditorView(notebookID: id)
            }
            .alert("새 노트북", isPresented: $isPresentingNewNotebookAlert) {
                TextField("노트북 이름", text: $newNotebookName)
                Button("취소", role: .cancel) {}
                Button("만들기") {
                    let notebook = library.createNotebook(named: newNotebookName)
                    navigationPath.append(notebook.id)
                }
            } message: {
                Text("노트북의 이름을 입력하세요.")
            }
        }
    }

    private func deleteNotebooks(at offsets: IndexSet) {
        for index in offsets {
            library.delete(id: library.notebooks[index].id)
        }
    }
}

private struct NotebookRow: View {
    let notebook: Notebook

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notebook.name)
                .font(.headline)
            Text("\(notebook.pages.count)페이지 · \(notebook.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotebookListView()
        .environment(NotebookLibrary())
}

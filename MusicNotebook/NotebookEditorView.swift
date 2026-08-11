//
//  NotebookEditorView.swift
//  MusicNotebook
//

import SwiftUI
import PencilKit

struct NotebookEditorView: View {
    let notebookID: UUID

    @Environment(NotebookLibrary.self) private var library
    @State private var currentPageIndex = 0
    @State private var isRenaming = false
    @State private var renameText = ""
    @State private var savedConfirmationText: String?
    @State private var isConfirmingPageDeletion = false
    @State private var fitToScreenTrigger = 0
    @State private var isShowingPageManager = false

    private var notebookIndex: Int? {
        library.notebooks.firstIndex(where: { $0.id == notebookID })
    }

    var body: some View {
        if let notebookIndex {
            let notebook = library.notebooks[notebookIndex]
            let pageIndex = min(currentPageIndex, notebook.pages.count - 1)

            DrawingCanvasView(
                drawing: Binding(
                    get: { library.notebooks[notebookIndex].pages[pageIndex].drawing },
                    set: { newValue in
                        library.mutate(id: notebookID) { $0.pages[pageIndex].drawing = newValue }
                    }
                ),
                pageSize: NotebookLayout.pageSize,
                fitToScreenTrigger: $fitToScreenTrigger
            )
            .id(notebook.pages[pageIndex].id)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(notebook.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        currentPageIndex = max(0, pageIndex - 1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(pageIndex == 0)

                    Text("\(pageIndex + 1) / \(notebook.pages.count)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)

                    Button {
                        currentPageIndex = min(notebook.pages.count - 1, pageIndex + 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(pageIndex == notebook.pages.count - 1)

                    Button {
                        fitToScreenTrigger += 1
                    } label: {
                        Label("화면에 맞추기", systemImage: "arrow.up.left.and.arrow.down.right")
                    }

                    Button {
                        isShowingPageManager = true
                    } label: {
                        Label("페이지 관리", systemImage: "square.grid.2x2")
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        renameText = notebook.name
                        isRenaming = true
                    } label: {
                        Label("이름 변경", systemImage: "pencil")
                    }

                    Button {
                        library.mutate(id: notebookID) { $0.pages.insert(NotebookPage(), at: pageIndex + 1) }
                        currentPageIndex = pageIndex + 1
                    } label: {
                        Label("페이지 추가", systemImage: "plus.square.on.square")
                    }

                    Button(role: .destructive) {
                        isConfirmingPageDeletion = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(notebook.pages.count <= 1)

                    Button {
                        library.save(notebook)
                        savedConfirmationText = "\"\(notebook.name)\" 저장됨"
                    } label: {
                        Label("저장", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .alert("노트북 이름 변경", isPresented: $isRenaming) {
                TextField("노트북 이름", text: $renameText)
                Button("취소", role: .cancel) {}
                Button("저장") {
                    library.rename(id: notebookID, to: renameText)
                }
            }
            .alert(savedConfirmationText ?? "", isPresented: Binding(
                get: { savedConfirmationText != nil },
                set: { if !$0 { savedConfirmationText = nil } }
            )) {
                Button("확인", role: .cancel) {}
            }
            .alert("이 페이지를 삭제하시겠습니까?", isPresented: $isConfirmingPageDeletion) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    library.mutate(id: notebookID) { $0.pages.remove(at: pageIndex) }
                    currentPageIndex = min(currentPageIndex, notebook.pages.count - 2)
                }
            } message: {
                Text("페이지 \(pageIndex + 1)의 필기 내용이 삭제되며 되돌릴 수 없습니다.")
            }
            .sheet(isPresented: $isShowingPageManager) {
                PageManagerView(notebookID: notebookID) { selectedIndex in
                    currentPageIndex = selectedIndex
                }
            }
        } else {
            ContentUnavailableView("노트북을 찾을 수 없습니다", systemImage: "exclamationmark.triangle")
        }
    }
}

//
//  PageManagerView.swift
//  MusicNotebook
//

import SwiftUI

/// Grid of page thumbnails for a notebook, letting the user jump to or delete any page directly
/// instead of stepping through pages one at a time.
struct PageManagerView: View {
    let notebookID: UUID
    var onSelectPage: (Int) -> Void

    @Environment(NotebookLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var pageIndexPendingDeletion: Int?

    private var notebook: Notebook? {
        library.notebooks.first(where: { $0.id == notebookID })
    }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 20)]

    var body: some View {
        NavigationStack {
            Group {
                if let notebook {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(Array(notebook.pages.enumerated()), id: \.element.id) { index, page in
                                PageThumbnailCell(
                                    page: page,
                                    pageNumber: index + 1,
                                    canDelete: notebook.pages.count > 1,
                                    onTap: {
                                        onSelectPage(index)
                                        dismiss()
                                    },
                                    onRequestDelete: {
                                        pageIndexPendingDeletion = index
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView("노트북을 찾을 수 없습니다", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("페이지 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
            .alert(
                "페이지 \((pageIndexPendingDeletion ?? 0) + 1)을(를) 삭제하시겠습니까?",
                isPresented: Binding(
                    get: { pageIndexPendingDeletion != nil },
                    set: { if !$0 { pageIndexPendingDeletion = nil } }
                )
            ) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    if let index = pageIndexPendingDeletion {
                        library.mutate(id: notebookID) { $0.pages.remove(at: index) }
                    }
                    pageIndexPendingDeletion = nil
                }
            } message: {
                Text("이 페이지의 필기 내용이 삭제되며 되돌릴 수 없습니다.")
            }
        }
    }
}

private struct PageThumbnailCell: View {
    let page: NotebookPage
    let pageNumber: Int
    let canDelete: Bool
    let onTap: () -> Void
    let onRequestDelete: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                Image(uiImage: page.thumbnail())
                    .resizable()
                    .aspectRatio(NotebookLayout.pageSize, contentMode: .fit)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            HStack {
                Text("페이지 \(pageNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(role: .destructive, action: onRequestDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .disabled(!canDelete)
            }
        }
    }
}

//
//  NotebookStore.swift
//  MusicNotebook
//

import Foundation
import Observation

@Observable
final class NotebookStore {
    var pages: [NotebookPage]
    var currentPageIndex: Int = 0

    private let fileURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("notebook.json")

        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([NotebookPage].self, from: data),
           !decoded.isEmpty {
            pages = decoded
        } else {
            pages = [NotebookPage()]
        }
    }

    var currentPage: NotebookPage {
        get { pages[currentPageIndex] }
        set { pages[currentPageIndex] = newValue }
    }

    func addPage() {
        pages.insert(NotebookPage(), at: currentPageIndex + 1)
        currentPageIndex += 1
        save()
    }

    func deleteCurrentPage() {
        guard pages.count > 1 else { return }
        pages.remove(at: currentPageIndex)
        currentPageIndex = min(currentPageIndex, pages.count - 1)
        save()
    }

    func goToPreviousPage() {
        guard currentPageIndex > 0 else { return }
        currentPageIndex -= 1
    }

    func goToNextPage() {
        guard currentPageIndex < pages.count - 1 else { return }
        currentPageIndex += 1
    }

    func save() {
        guard let data = try? JSONEncoder().encode(pages) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

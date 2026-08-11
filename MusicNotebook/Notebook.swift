//
//  Notebook.swift
//  MusicNotebook
//

import Foundation

struct Notebook: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var pages: [NotebookPage]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        pages: [NotebookPage] = [NotebookPage()],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.pages = pages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

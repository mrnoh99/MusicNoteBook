//
//  NotebookLibrary.swift
//  MusicNotebook
//

import Foundation
import Observation

/// Manages the collection of named notebooks, each persisted as its own
/// JSON file under Documents/Notebooks/<id>.json.
@Observable
final class NotebookLibrary {
    var notebooks: [Notebook] = []

    private let directoryURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directoryURL = documents.appendingPathComponent("Notebooks", isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        load()
    }

    private func fileURL(for notebook: Notebook) -> URL {
        directoryURL.appendingPathComponent("\(notebook.id.uuidString).json")
    }

    func load() {
        let files = (try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)) ?? []
        notebooks = files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(Notebook.self, from: data)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    @discardableResult
    func createNotebook(named name: String) -> Notebook {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let notebook = Notebook(name: trimmed.isEmpty ? "제목 없는 노트북" : trimmed)
        notebooks.insert(notebook, at: 0)
        save(notebook)
        return notebook
    }

    func rename(id: UUID, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = notebooks.firstIndex(where: { $0.id == id }) else { return }
        notebooks[index].name = trimmed
        notebooks[index].updatedAt = Date()
        save(notebooks[index])
    }

    func delete(id: UUID) {
        guard let notebook = notebooks.first(where: { $0.id == id }) else { return }
        notebooks.removeAll { $0.id == id }
        try? FileManager.default.removeItem(at: fileURL(for: notebook))
    }

    /// Persists the notebook at `id` using the transform, updating `updatedAt`.
    func mutate(id: UUID, _ transform: (inout Notebook) -> Void) {
        guard let index = notebooks.firstIndex(where: { $0.id == id }) else { return }
        transform(&notebooks[index])
        notebooks[index].updatedAt = Date()
        save(notebooks[index])
    }

    func save(_ notebook: Notebook) {
        guard let data = try? JSONEncoder().encode(notebook) else { return }
        try? data.write(to: fileURL(for: notebook), options: .atomic)
    }
}

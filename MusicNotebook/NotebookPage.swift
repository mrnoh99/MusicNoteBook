//
//  NotebookPage.swift
//  MusicNotebook
//

import Foundation
import PencilKit

struct NotebookPage: Identifiable, Codable, Equatable {
    let id: UUID
    var drawingData: Data

    init(id: UUID = UUID(), drawingData: Data = PKDrawing().dataRepresentation()) {
        self.id = id
        self.drawingData = drawingData
    }

    var drawing: PKDrawing {
        get { (try? PKDrawing(data: drawingData)) ?? PKDrawing() }
        set { drawingData = newValue.dataRepresentation() }
    }
}

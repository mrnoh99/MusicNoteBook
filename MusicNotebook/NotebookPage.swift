//
//  NotebookPage.swift
//  MusicNotebook
//

import Foundation
import PencilKit
import UIKit

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

    /// Renders the staff background plus ink into a small preview image for the page manager.
    func thumbnail(pageSize: CGSize = NotebookLayout.pageSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: pageSize, format: format)
        return renderer.image { context in
            let staffView = StaffPaperView(frame: CGRect(origin: .zero, size: pageSize))
            staffView.layer.render(in: context.cgContext)

            let inkImage = drawing.image(from: CGRect(origin: .zero, size: pageSize), scale: 1)
            inkImage.draw(in: CGRect(origin: .zero, size: pageSize))
        }
    }
}

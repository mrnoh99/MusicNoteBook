//
//  DrawingCanvasView.swift
//  MusicNotebook
//

import SwiftUI
import PencilKit

/// A pinch-to-zoom page that layers an Apple Pencil drawing canvas on top of
/// a printed 5-line staff background. Both layers zoom and pan together.
struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var pageSize: CGSize
    /// Incremented externally (e.g. by a toolbar button) to snap the page back to fit-to-screen zoom.
    @Binding var fitToScreenTrigger: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 4.0
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .secondarySystemBackground
        scrollView.contentInsetAdjustmentBehavior = .never

        let container = UIView(frame: CGRect(origin: .zero, size: pageSize))
        container.backgroundColor = .clear

        let staffView = StaffPaperView(frame: container.bounds)
        staffView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(staffView)

        let canvas = PKCanvasView(frame: container.bounds)
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.isScrollEnabled = false
        container.addSubview(canvas)

        scrollView.addSubview(container)
        scrollView.contentSize = pageSize

        context.coordinator.scrollView = scrollView
        context.coordinator.containerView = container
        context.coordinator.canvasView = canvas
        context.coordinator.pageSize = pageSize
        context.coordinator.lastFitTrigger = fitToScreenTrigger

        DispatchQueue.main.async {
            context.coordinator.fitToScreen(animated: false)
            context.coordinator.showToolPicker()
        }

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard let canvas = context.coordinator.canvasView else { return }
        if canvas.drawing.dataRepresentation() != drawing.dataRepresentation() {
            canvas.drawing = drawing
        }
        if context.coordinator.lastFitTrigger != fitToScreenTrigger {
            context.coordinator.lastFitTrigger = fitToScreenTrigger
            context.coordinator.fitToScreen(animated: true)
        }
        context.coordinator.showToolPicker()
    }

    static func dismantleUIView(_ scrollView: UIScrollView, coordinator: Coordinator) {
        coordinator.hideToolPicker()
    }

    final class Coordinator: NSObject, UIScrollViewDelegate, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        weak var scrollView: UIScrollView?
        weak var containerView: UIView?
        weak var canvasView: PKCanvasView?
        var pageSize: CGSize = .zero
        var lastFitTrigger = 0
        private var toolPicker: PKToolPicker?

        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            containerView
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }

        /// Zooms so the page width fills the screen in one step, matching the initial layout.
        func fitToScreen(animated: Bool) {
            guard let scrollView, scrollView.bounds.width > 0, pageSize.width > 0 else { return }
            let scale = scrollView.bounds.width / pageSize.width
            let clamped = max(scrollView.minimumZoomScale, min(scale, scrollView.maximumZoomScale))
            scrollView.setZoomScale(clamped, animated: animated)
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.adjustedContentInset.top), animated: animated)
        }

        func showToolPicker() {
            guard let canvasView, let window = canvasView.window else { return }
            guard let picker = PKToolPicker.shared(for: window) else { return }
            picker.setVisible(true, forFirstResponder: canvasView)
            picker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            toolPicker = picker
        }

        func hideToolPicker() {
            guard let canvasView, let toolPicker else { return }
            toolPicker.setVisible(false, forFirstResponder: canvasView)
        }
    }
}

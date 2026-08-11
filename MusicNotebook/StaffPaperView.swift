//
//  StaffPaperView.swift
//  MusicNotebook
//

import UIKit

/// Draws repeating 5-line music staves on a cream paper background.
final class StaffPaperView: UIView {
    var lineSpacing: CGFloat = 9
    var staffGroupSpacing: CGFloat = 80
    var topMargin: CGFloat = 70
    var sideMargin: CGFloat = 50
    var lineColor = UIColor(red: 0.52, green: 0.55, blue: 0.47, alpha: 0.55)
    var paperColor = UIColor(red: 0.972, green: 0.961, blue: 0.902, alpha: 1.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = paperColor
        contentMode = .redraw
        isOpaque = true
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        paperColor.setFill()
        ctx.fill(bounds)

        let left = sideMargin
        let right = bounds.width - sideMargin
        guard right > left else { return }

        let scale = window?.screen.scale ?? UIScreen.main.scale
        ctx.setStrokeColor(lineColor.cgColor)
        ctx.setLineWidth(1.0 / scale)

        var y = topMargin
        let staffHeight = lineSpacing * 4
        while y + staffHeight <= bounds.height - topMargin {
            for lineIndex in 0..<5 {
                let lineY = (y + CGFloat(lineIndex) * lineSpacing).rounded() + 0.5
                ctx.move(to: CGPoint(x: left, y: lineY))
                ctx.addLine(to: CGPoint(x: right, y: lineY))
            }
            ctx.strokePath()
            y += staffGroupSpacing
        }
    }
}

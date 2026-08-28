import AppKit
import CoreGraphics
import CoreText

struct IconRenderer {
    let size: CGFloat

    func render() -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        image.unlockFocus()
        return image
    }

    private func draw(in rect: CGRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)

        NSColor.clear.setFill()
        rect.fill()

        drawBackground(in: rect, context: context)
        drawTMark(in: rect, context: context)
    }

    private func drawBackground(in rect: CGRect, context: CGContext) {
        let inset = size * 0.018
        let backgroundRect = rect.insetBy(dx: inset, dy: inset)
        let radius = size * 0.236
        let backgroundPath = CGPath(roundedRect: backgroundRect, cornerWidth: radius, cornerHeight: radius, transform: nil)

        context.saveGState()
        context.addPath(backgroundPath)
        context.setShadow(
            offset: CGSize(width: 0, height: -size * 0.018),
            blur: size * 0.036,
            color: NSColor(calibratedRed: 0.02, green: 0.12, blue: 0.30, alpha: 0.22).cgColor
        )
        context.setFillColor(NSColor(calibratedRed: 0.05, green: 0.31, blue: 0.78, alpha: 1.0).cgColor)
        context.fillPath()
        context.restoreGState()

        context.saveGState()
        context.addPath(backgroundPath)
        context.clip()

        let baseGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                NSColor(calibratedRed: 0.63, green: 0.90, blue: 1.0, alpha: 1.0).cgColor,
                NSColor(calibratedRed: 0.12, green: 0.50, blue: 0.95, alpha: 1.0).cgColor,
                NSColor(calibratedRed: 0.02, green: 0.18, blue: 0.55, alpha: 1.0).cgColor
            ] as CFArray,
            locations: [0.0, 0.44, 1.0]
        )!
        context.drawLinearGradient(
            baseGradient,
            start: CGPoint(x: backgroundRect.minX + backgroundRect.width * 0.12, y: backgroundRect.maxY),
            end: CGPoint(x: backgroundRect.maxX, y: backgroundRect.minY + backgroundRect.height * 0.10),
            options: []
        )
        context.restoreGState()
    }

    private func drawTMark(in rect: CGRect, context: CGContext) {
        let path = makeRoundedTPath(in: rect)
        let pathBounds = path.boundingBoxOfPath

        context.saveGState()
        context.addPath(path)
        context.setShadow(
            offset: CGSize(width: 0, height: -size * 0.022),
            blur: size * 0.038,
            color: NSColor(calibratedRed: 0.01, green: 0.05, blue: 0.18, alpha: 0.30).cgColor
        )
        context.setFillColor(NSColor(calibratedWhite: 1.0, alpha: 0.14).cgColor)
        context.fillPath()
        context.restoreGState()

        context.saveGState()
        context.addPath(path)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(size * 0.030)
        context.setStrokeColor(NSColor(calibratedWhite: 1.0, alpha: 0.88).cgColor)
        context.strokePath()
        context.restoreGState()

        let fadeStartY = pathBounds.minY + pathBounds.height * 0.485
        let fadeEndY = pathBounds.minY + pathBounds.height * 0.170

        context.saveGState()
        context.addPath(path)
        context.clip()
        let fadeGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                NSColor(calibratedRed: 0.73, green: 0.91, blue: 1.0, alpha: 0.0).cgColor,
                NSColor(calibratedRed: 0.74, green: 0.90, blue: 1.0, alpha: 0.38).cgColor,
                NSColor(calibratedWhite: 1.0, alpha: 0.95).cgColor
            ] as CFArray,
            locations: [0.0, 0.55, 1.0]
        )!
        context.drawLinearGradient(
            fadeGradient,
            start: CGPoint(x: pathBounds.midX, y: fadeEndY),
            end: CGPoint(x: pathBounds.midX, y: fadeStartY),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )
        context.restoreGState()

        drawTailFragments(pathBounds: pathBounds, context: context)
    }

    private func makeRoundedTPath(in rect: CGRect) -> CGPath {
        let left = rect.minX + size * 0.205
        let right = rect.maxX - size * 0.205
        let top = rect.minY + size * 0.828
        let barBottom = rect.minY + size * 0.704
        let stemLeft = rect.midX - size * 0.064
        let stemRight = rect.midX + size * 0.064
        let bottom = rect.minY + size * 0.156
        let outerRadius = size * 0.026
        let innerRadius = size * 0.018

        let path = CGMutablePath()
        path.move(to: CGPoint(x: left + outerRadius, y: top))
        path.addLine(to: CGPoint(x: right - outerRadius, y: top))
        path.addQuadCurve(to: CGPoint(x: right, y: top - outerRadius), control: CGPoint(x: right, y: top))
        path.addLine(to: CGPoint(x: right, y: barBottom + outerRadius))
        path.addQuadCurve(to: CGPoint(x: right - outerRadius, y: barBottom), control: CGPoint(x: right, y: barBottom))
        path.addLine(to: CGPoint(x: stemRight + innerRadius, y: barBottom))
        path.addQuadCurve(to: CGPoint(x: stemRight, y: barBottom - innerRadius), control: CGPoint(x: stemRight, y: barBottom))
        path.addLine(to: CGPoint(x: stemRight, y: bottom + outerRadius))
        path.addQuadCurve(to: CGPoint(x: stemRight - outerRadius, y: bottom), control: CGPoint(x: stemRight, y: bottom))
        path.addLine(to: CGPoint(x: stemLeft + outerRadius, y: bottom))
        path.addQuadCurve(to: CGPoint(x: stemLeft, y: bottom + outerRadius), control: CGPoint(x: stemLeft, y: bottom))
        path.addLine(to: CGPoint(x: stemLeft, y: barBottom - innerRadius))
        path.addQuadCurve(to: CGPoint(x: stemLeft - innerRadius, y: barBottom), control: CGPoint(x: stemLeft, y: barBottom))
        path.addLine(to: CGPoint(x: left + outerRadius, y: barBottom))
        path.addQuadCurve(to: CGPoint(x: left, y: barBottom + outerRadius), control: CGPoint(x: left, y: barBottom))
        path.addLine(to: CGPoint(x: left, y: top - outerRadius))
        path.addQuadCurve(to: CGPoint(x: left + outerRadius, y: top), control: CGPoint(x: left, y: top))
        path.closeSubpath()
        return path
    }

    private func drawTailFragments(pathBounds: CGRect, context: CGContext) {
        let origin = CGPoint(x: pathBounds.midX, y: pathBounds.minY + pathBounds.height * 0.180)
        let fragments: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-0.075, 0.036, 0.024, 0.70),
            (0.060, 0.022, 0.021, 0.62),
            (-0.030, -0.012, 0.018, 0.52),
            (0.022, -0.040, 0.015, 0.44),
            (-0.098, -0.060, 0.013, 0.36),
            (0.090, -0.076, 0.012, 0.32),
            (-0.044, -0.105, 0.010, 0.26),
            (0.046, -0.132, 0.008, 0.20),
            (-0.012, -0.164, 0.006, 0.14)
        ]

        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: -size * 0.004),
            blur: size * 0.008,
            color: NSColor(calibratedRed: 0.02, green: 0.09, blue: 0.26, alpha: 0.18).cgColor
        )

        for (dx, dy, scale, alpha) in fragments {
            let side = max(1.0, size * scale)
            let rect = CGRect(
                x: origin.x + size * dx - side / 2,
                y: origin.y + size * dy - side / 2,
                width: side,
                height: side
            )
            roundedFill(
                rect,
                radius: side * 0.18,
                color: NSColor(calibratedWhite: 1.0, alpha: alpha),
                context: context
            )
        }

        context.restoreGState()
    }

    private func roundedFill(_ rect: CGRect, radius: CGFloat, color: NSColor, context: CGContext) {
        context.saveGState()
        context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
        context.setFillColor(color.cgColor)
        context.fillPath()
        context.restoreGState()
    }
}

func writePNG(_ image: NSImage, to url: URL) throws {
    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "IconRenderer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create PNG data"])
    }
    try pngData.write(to: url)
}

let outputPath = CommandLine.arguments.dropFirst().first ?? "."
let output = URL(fileURLWithPath: outputPath)

if output.pathExtension.lowercased() == "png" {
    try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
    let image = IconRenderer(size: 1024).render()
    try writePNG(image, to: output)
    exit(0)
}

try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (filename, size) in sizes {
    let image = IconRenderer(size: size).render()
    try writePNG(image, to: output.appendingPathComponent(filename))
}

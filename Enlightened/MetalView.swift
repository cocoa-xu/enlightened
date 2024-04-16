//
//  MetalView.swift
//  Enlightened
//
//  Created by Dmitry Starkov on 28/03/2023.
//  Modified by Cocoa on 13/04/2024.
//

import Cocoa
import MetalKit

// Metal view displaying static HDR content to enable EDR display mode
class MetalView: MTKView, MTKViewDelegate {
    private let colorSpace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
    // values from 1.0 to 3.0, where 1.0 is optimal
    private var contrast: Float
    // values from 0.0 to 3.0, where 1.0 is optimal
    private var brightness: Float

    private var commandQueue: MTLCommandQueue?
    private var renderContext: CIContext?

    private var image: CIImage?

    /// Public initializer
    /// - frameRate: lower the frame rate for better perfomance, otherwise the screen frame rate is used (probably 120)
    /// - contrast: value use by `CIColorControls` `CIFilter`
    /// - brightness: value use by `CIColorControls` `CIFilter`
    init(frame: CGRect, frameRate: Int? = nil, contrast: Float = 1.0, brightness: Float = 1.0, screenIndex: Int? = nil) {
        self.contrast = contrast
        self.brightness = brightness
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())

        if let device = self.device {
            self.commandQueue = device.makeCommandQueue()
            if let commandQueue = self.commandQueue {
                self.renderContext = CIContext(mtlCommandQueue: commandQueue, options: [
                    .name: "EnlightenedContext",
                    .workingColorSpace: colorSpace ?? CGColorSpace.extendedLinearSRGB,
                    .workingFormat: CIFormat.RGBAf,
                    .cacheIntermediates: true,
                    .allowLowPower: false,
                ])
            }
        }
        self.delegate = self

        // Allow the view to display its contents outside of the framebuffer and bind the delegate to the coordinator
        self.framebufferOnly = false
        // Update FPS (matter only on space switching or on/off HDR brightness mode)
        if let frameRate = frameRate {
            self.preferredFramesPerSecond = frameRate
        } else {
            if #available(macOS 12.0, *) {
                self.preferredFramesPerSecond = NSScreen.main?.maximumFramesPerSecond ?? 120
            } else {
                self.preferredFramesPerSecond = 120
            }
        }
        
        // Enable EDR
        self.colorPixelFormat = .rgba16Float
        self.colorspace = colorSpace
        if let layer = self.layer as? CAMetalLayer {
            layer.wantsExtendedDynamicRangeContent = true
            layer.isOpaque = false
            // Blend EDR layer with background
            layer.compositingFilter = "multiplyBlendMode"
        }
        guard let colorControlsFilter = CIFilter(name: "CIColorControls") else { return }
        // default to 1.0
        colorControlsFilter.setValue(contrast, forKey: kCIInputContrastKey)
        // default to 0.0
        colorControlsFilter.setValue(brightness, forKey: kCIInputBrightnessKey)

        // Transparent color in EDR color space
        guard let colorSpace = colorSpace, let color = CIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0, colorSpace: colorSpace) else {
            return
        }
        var transparent: CIImage?
        colorControlsFilter.setValue(CIImage(color: color), forKey: kCIInputImageKey)
        if let image = colorControlsFilter.outputImage {
            transparent = image
        }

        self.image = transparent
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func draw(in view: MTKView) {
        guard let image = image, let colorSpace = colorSpace else { return  }
        guard let commandQueue = commandQueue, let renderContext = renderContext else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer(), let drawable = currentDrawable else { return }
        renderContext.render(image, to: drawable.texture, commandBuffer: commandBuffer, bounds: CGRect(origin: CGPoint.zero, size: drawableSize), colorSpace: colorSpace)
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
}

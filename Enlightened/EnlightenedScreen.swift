//
//  EnlightenedScreen.swift
//  Enlightened
//
//  Created by Cocoa on 16/04/2024.
//

import Foundation
import Cocoa
import AppKit

class EnlightenedScreen : NSMenuItem {
    var screen: NSScreen!
    var window: NSWindow!
    var metalView: MetalView!
    
    var enlightened: Bool! = false {
        didSet {
            if screen == nil {
                if window != nil && metalView != nil {
                    // Remove the metal view
                    guard let view = window.contentView else { return }
                    if view.subviews.contains(metalView) {
                        metalView.removeFromSuperview()
                        metalView = nil
                    }
                    window = nil
                }
            } else {
                if enlightened {
                    let fullScreenRect = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
                    if window == nil {
                        window = NSWindow(contentRect: fullScreenRect, styleMask: [.borderless], backing: .buffered, defer: false)
                    }
                    
                    window.setFrame(fullScreenRect, display: true, animate: false)
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.ignoresMouseEvents = true
                    
                    // Set the window's level to mainMenu to make it float above all other windows
                    // Requires "Application is agent (UIElement)" set to "YES" in info.plist for system-wide support
                    // The maximum possible values is NSWindow.Level(rawValue: Int(CGShieldingWindowLevel() + 19))
                    window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel() + 19))
                    
                    // Allow window to overlay in Mission Control and Spaces
                    window.collectionBehavior = [.stationary, .canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle] // .managed

                    // Keep visible all time (required for overlays)
                    window.hidesOnDeactivate = false

                    // Add metal view with HDR overlay
                    guard let view = window.contentView else { return }
                    // The contrast and brightness can be adjust for a brighter effect, at the expense of color correctness
                    metalView = MetalView(frame: view.bounds, frameRate: 3, contrast: 1.0, brightness: 1.0)
                    metalView.autoresizingMask = [.width, .height]
                    view.addSubview(metalView)

                    // move to this screen
                    var pos = NSPoint()
                    pos.x = screen.frame.minX
                    pos.y = screen.frame.minY
                    window.setFrameOrigin(pos)
                    
                    // Present the window
                    window.makeKeyAndOrderFront(nil)
                } else {
                    if window != nil && metalView != nil {
                        // Remove the metal view
                        guard let view = window.contentView else { return }
                        if view.subviews.contains(metalView) {
                            metalView.removeFromSuperview()
                            metalView = nil
                        }
                    }
                }
            }
        }
    }
}

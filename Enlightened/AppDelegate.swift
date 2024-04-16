//
//  AppDelegate.swift
//  Enlightened
//
//  Created by Cocoa on 13/04/2024.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var knownScreens: Set<NSScreen>!
    var statusBarItem: NSStatusItem!
    var menu: NSMenu
    var statusMenu: NSMenu
    var preferencesItem: NSMenuItem!
    var quitItem: NSMenuItem!
    
    required override init() {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: 18)

        self.menu = NSMenu.init()
        self.statusBarItem.menu = self.menu
        if let button = self.statusBarItem.button {
            button.image = NSImage(systemSymbolName: "warninglight", accessibilityDescription: nil)
        }
        
        self.statusMenu = NSMenu(title: "EnlightenedStatusMenu")
        self.quitItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: "q")
        self.statusBarItem.menu = statusMenu
        
        self.knownScreens = Set()
        
        super.init()
        self.statusMenu.addItem(NSMenuItem.separator())
        self.statusMenu.addItem(self.quitItem)
        self.updateMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisplayConnection), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
    
    @objc func handleDisplayConnection(notification: Notification) {
        updateMenu()
    }
    
    @objc func toggleEnlighten(sender: EnlightenedScreen) {
        sender.enlightened = !sender.enlightened
        if sender.enlightened {
            sender.state = .on
        } else {
            sender.state = .off
        }
    }
    
    func updateMenu() {
        var newScreens = Set<NSScreen>()
        var removedScreens = Set(self.knownScreens)
        NSScreen.screens.forEach { screen in
            if knownScreens.contains(screen) {
                removedScreens.remove(screen)
            } else {
                newScreens.insert(screen)
            }
        }
        
        var removedItems: [NSMenuItem] = Array()
        removedScreens.forEach { screen in
            self.statusMenu.items.forEach { menuItem in
                guard let enlightenedScreen = menuItem as? EnlightenedScreen else {
                    return
                }
                enlightenedScreen.enlightened = false
                removedItems.append(enlightenedScreen)
            }
            self.knownScreens.remove(screen)
        }
        removedItems.forEach { removed in
            self.statusMenu.removeItem(removed)
        }
        
        newScreens.forEach { screen in
            let detailMenu = EnlightenedScreen(title: screen.localizedName, action: #selector(AppDelegate.toggleEnlighten), keyEquivalent: "")
            detailMenu.screen = screen
            detailMenu.enlightened = false
            self.statusMenu.insertItem(detailMenu, at: self.statusMenu.items.count - 2)
            self.knownScreens.insert(screen)
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

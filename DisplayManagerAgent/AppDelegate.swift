//
//  AppDelegate.swift
//  DisplayManagerAgent
//
//  Created by Daniel Fortesque on 02/05/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = NSImage(systemSymbolName: "display", accessibilityDescription: nil)
        statusBarItem.button?.target = self
        statusBarItem.button?.action = #selector(presentItem)
        
    }
    
    @objc func presentItem() {
        let view = ContentView(isStatusBarItem: true)
            .frame(maxWidth: 350)
        
        let vc = NSHostingController(rootView: view)
        
        guard let button = statusBarItem.button else {
            fatalError("Couldn't find status item button.")
        }
        
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        
    }
    
    @objc private func increase() {
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}


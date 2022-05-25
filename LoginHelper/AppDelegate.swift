//
//  AppDelegate.swift
//  LoginHelper
//
//  Created by Daniel Fortesque on 02/05/21.
//

import Cocoa
import SwiftUI
import CoreGraphics

@main
class AppDelegate: NSObject, NSApplicationDelegate, SuperObserverDelegate {

    var window: NSWindow!

    let defaults = UserDefaults(suiteName: "R779A64KR9.com.danxnu.displaymanager")
    
    let superObserver = SuperObserver()
    let superManager = SuperManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let config = Config.getDefault()
        print("Current config: \(config.configs)")
        
        let mainAppRunning = NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == mainAppBundle })
        
        if !mainAppRunning {
            let monitors = Monitor.getAllMonitors()
            for monitor in monitors {
                guard let mode = config.configs[monitor.id] else { continue }
                monitor.setNewMode(mode: mode)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .init(rawValue: "config-applied"), object: nil, queue: .main) { notification in
//            guard let config = notification.userInfo?["config"] as? SuperConfiguration else { return }
                
//            self.presentAlertController(config: config)
        }
    
        superObserver.delegate = self
        superObserver.registerDisplay()
        
        superManager.searchAndApplyConfig()

//        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        superObserver.deactivateDisplay()
    }
    
    func displayChanged(_ displayID: CGDirectDisplayID, flags: CGDisplayChangeSummaryFlags, userInfo: UnsafeMutableRawPointer?) {
        if flags.contains(.addFlag) {
            print("YOOOO")
            superManager.searchAndApplyConfig()
        }
    }
    
    func presentAlertController(config: SuperConfiguration) {
        guard let screen = NSScreen.main else { return }
        
        let vc = NSHostingController(rootView: AlertView(config: config))
        vc.view.frame = screen.frame
        vc.view.layer?.backgroundColor = .clear
        
        let newWindow = NSPanel(contentViewController: vc)
        newWindow.styleMask =  NSWindow.StyleMask.hudWindow
        newWindow.setFrameOrigin(screen.visibleFrame.origin)
        newWindow.isMovable = false
        newWindow.isMovableByWindowBackground = false
        
        let windowController = NSWindowController(window: newWindow)
        windowController.showWindow(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            windowController.dismissController(self)
            windowController.close()
        }
        
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
    }
}


struct AlertView: View {
    var config: SuperConfiguration
    
    var body: some View {
        VStack {
            Text(config.name)
                .bold()
                .font(.system(size: 128))
            Text("Display mode activated!")
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

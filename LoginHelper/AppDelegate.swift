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
}


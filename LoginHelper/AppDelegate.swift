//
//  AppDelegate.swift
//  LoginHelper
//
//  Created by Daniel Fortesque on 02/05/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    let defaults = UserDefaults(suiteName: "R779A64KR9.com.danxnu.displaymanager")
    
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
        
        
        
//        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


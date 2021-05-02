//
//  ViewModel.swift
//  GHDisplayManager
//
//  Created by Daniel Fortesque on 30/04/21.
//

import Foundation
import Combine
import AppKit
import SwiftUI
import ServiceManagement

class ViewModel: ObservableObject {
    
    @Published var monitors : [Monitor] = []
    @Published var hoveredMonitor: Monitor?
    
    @Published var defaultConfig: Config = Config.getDefault()
    @Published var loginServiceActive: Bool = false
    
    var presentedWindow: NSWindowController?
    
    private var observers: [AnyCancellable] = []
    
    init() {
        loginServiceActive = isServiceRunning
        
        let nc = NotificationCenter.default
            nc.addObserver(self,
                           selector: #selector(update),
                           name: NSApplication.didChangeScreenParametersNotification,
                           object: nil)
        update()
    }
    
    @objc func update() {
        self.monitors = Monitor.getAllMonitors().sorted(by: { $0.number < $1.number })
        
        free()

        for monitor in monitors {
            let obs = monitor.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            observers.append(obs)
        }
    }
    
    func free() {
        observers.forEach { $0.cancel() }
        observers.removeAll()
    }
    
    
    func show(monitor: Monitor) {
        guard let screen = NSScreen.screens.first(where: { screen in
            let key = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
            return screen.deviceDescription[key] as? UInt32 == monitor.number
        }) else {
            return
        }
        
        dismissPlaceholder()
        
        let vc = NSHostingController(rootView: PlaceholderView(monitor: monitor))
        vc.view.frame = screen.frame
        vc.view.layer?.backgroundColor = .clear
        
        let newWindow = NSPanel(contentViewController: vc)
        newWindow.styleMask =  NSWindow.StyleMask.hudWindow
        newWindow.setFrameOrigin(screen.visibleFrame.origin)
        newWindow.isMovable = false
        newWindow.isMovableByWindowBackground = false
        
        presentedWindow = NSWindowController(window: newWindow)
        presentedWindow?.showWindow(nil)
        
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
    }
    
    func dismissPlaceholder() {
        hoveredMonitor = nil
        
        presentedWindow?.dismissController(self)
        presentedWindow?.close()
        presentedWindow = nil
    }
    
    func saveConfig() {
        defaultConfig.configs.removeAll()
        
        for monitor in self.monitors {
            defaultConfig.configs[monitor.id] = monitor.currentMode
        }

        defaultConfig.save()
    }
    
    func restoreDefaults() {
        for monitor in self.monitors {
            guard let mode = self.defaultConfig.configs[monitor.id] else { continue }
                
            monitor.setNewMode(mode: mode)
        }
    }
    
    func activateOnStartup(activate: Bool = true) {
        let success = SMLoginItemSetEnabled(loginHelperBundle as CFString, activate)
        print("Success: \(success)")
    }
    
    private var isServiceRunning: Bool {
        return NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == loginHelperBundle })
    }
    
    var hasChanged: Bool {
        for monitor in monitors {
            guard let savedConfig = defaultConfig.configs[monitor.id] else { continue }
            let currentConfig = monitor.currentMode
            
            let changed = savedConfig.width != currentConfig.width || savedConfig.height != currentConfig.height || savedConfig.freq != currentConfig.freq || savedConfig.density != currentConfig.density
            
            if changed {
                return true
            }
        }
        return false
    }
}

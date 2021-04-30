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

class ViewModel: ObservableObject {
    
    @Published var monitors : [Monitor] = []
    @Published var hoveredMonitor: Monitor?
    
    var presentedWindow: NSWindowController?
    
    private var observers: [AnyCancellable] = []
    
    init() {
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
    
    func getModes(for monitor: Monitor) -> [String] {
        let manager = DisplayManager()
        let modes = monitor.getAvailableModes()
    
    
        
    }
    
    
    func free() {
        observers.forEach { $0.cancel() }
        observers.removeAll()
    }
    
    func showPlaceholder(in monitor: Monitor) {
        hoveredMonitor = monitor
        
    }
    
    func dismissPlaceholder() {
        hoveredMonitor = nil
        
        presentedWindow?.dismissController(self)
        presentedWindow?.close()
        presentedWindow = nil
    }
}

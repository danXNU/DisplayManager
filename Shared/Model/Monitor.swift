//
//  Monitor.swift
//  GHDisplayManager
//
//  Created by Daniel Fortesque on 30/04/21.
//

import Foundation
import ApplicationServices

class Monitor: ObservableObject {
    var number: UInt32
    var id: UUID
    @Published var currentMode: Mode
    
    //cache
    private var _availableModes : [Mode] = []
    
    init(number: UInt32, id: UUID, currentMode: Mode) {
        self.number = number
        self.id = id
        self.currentMode = currentMode
        
        DispatchQueue.global(qos: .userInitiated).async {
            _ = self.getAvailableModes()
        }
    }
    
    static func getAllMonitors() -> [Monitor] {
        let manager = DisplayManager()
        
        var monitors : [Monitor] = []
        let monitorNumbers = manager.getActiveMonitors()
        
        for monitorNumber in monitorNumbers {
            let uuid = manager.getUUIDFromDisplay(monitorNumber)
            let rawMode = manager.getModeFromDisplayNumber(CGDirectDisplayID(monitorNumber.intValue))
            let mode = Mode(rawMode: rawMode)
            
            let monitor = Monitor(number: monitorNumber.uint32Value,
                                  id: uuid,
                                  currentMode: mode)
            monitors.append(monitor)
        }
        
        return monitors
    }
    
    func setNewMode(mode: Mode) {
        let manager = DisplayManager()
        manager.applyMode(UInt(mode.id), toMonitorID: self.id)
        self.currentMode = mode
    }
    
    func getAvailableModes() -> [Mode] {
        if !_availableModes.isEmpty {
            return _availableModes
        }
        
        let manager = DisplayManager()
        let rawModes = manager.getModesForMonitor(self.id)
        
        var newModes : [Mode] = []
        
        for rawMode in rawModes {
            let width = rawMode["width"] as! NSNumber
            let height = rawMode["height"] as! NSNumber
            let freq = rawMode["freq"] as! NSNumber
            let modeID = rawMode["modeID"] as! NSNumber
            let density = rawMode["density"] as! NSNumber

            let newMode = Mode(width: width,
                               height: height,
                               freq: freq,
                               density: density,
                               id: modeID)
            newModes.append(newMode)
        }
                
        self._availableModes = newModes
        
        return newModes
    }

}

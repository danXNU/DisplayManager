//
//  SuperMonitor.swift
//  GHDisplayManager
//
//  Created by Daniel Bazzani on 24/05/22.
//

import Foundation

struct SuperConfiguration: Codable, Identifiable {
    var name: String
    var configMap: [UUID: MonitorConfig]
    
    var id: String {
        name
    }
    
    var displays: Set<UUID> {
        Set(configMap.keys)
    }
    
    var rawRepresentation: NSArray {
        let arr = NSMutableArray()
        for displayUUID in displays {
            guard let ogConf = configMap[displayUUID] else { continue }
            let newDict = NSDictionary(dictionary: [
                "id": displayUUID,
                "rect": NSDictionary(dictionary: [ "x": ogConf.rect.origin.x, "y": ogConf.rect.origin.y])
            ])
            arr.add(newDict)
        }
        
        return arr as NSArray
    }
}

struct MonitorConfig: Codable {
    var rect: CGRect
    var isMain: Bool
}

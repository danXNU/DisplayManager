//
//  SuperMonitor.swift
//  GHDisplayManager
//
//  Created by Daniel Bazzani on 24/05/22.
//

import Foundation

struct SuperConfiguration: Codable, Identifiable, Hashable, Equatable {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: SuperConfiguration, rhs: SuperConfiguration) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MonitorConfig: Codable {
    var rect: CGRect
    var isMain: Bool
}

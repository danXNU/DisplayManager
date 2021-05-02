//
//  Mode.swift
//  GHDisplayManager
//
//  Created by Daniel Fortesque on 30/04/21.
//

import Foundation

struct Mode: Hashable, Codable {
    var width: UInt32
    var height: UInt32
    var freq: UInt16
    var density: Float
    
    var id: UInt32
    
    init(width: NSNumber, height: NSNumber, freq: NSNumber, density: NSNumber, id: NSNumber) {
        self.width = width.uint32Value
        self.height = height.uint32Value
        self.freq = freq.uint16Value
        self.density = density.floatValue
        
        self.id = id.uint32Value
    }
    
    init(rawMode: CGSDisplayMode) {
        self.id = rawMode.modeNumber
        self.width = rawMode.width
        self.height = rawMode.height
        self.freq = rawMode.freq
        self.density = rawMode.density
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    
    enum Style {
        case full
        case medium
        case min
    }
    
    func string(style: Style) -> String {
        switch style {
        case .min:
            return "\(width) x \(height)"
        case .full:
            return "\(width) x \(height) @ \(freq)Hz - \(Int(density))x"
        case .medium:
            return "\(width) x \(height) @ \(freq)Hz"
        }
    }
}

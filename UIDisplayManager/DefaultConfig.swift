//
//  DefaultConfig.swift
//  UIDisplayManager
//
//  Created by Daniel Fortesque on 30/04/21.
//

import Foundation

struct Config: Codable {
    var configs: [UUID: Mode] = [:]
    
    private static let defaultKey = "defaultConfig"
        
    static func getDefault() -> Config {
        guard let data = UserDefaults.standard.data(forKey: defaultKey) else {
            return Config()
        }
        
        guard let config = try? JSONDecoder().decode(Config.self, from: data) else {
            return Config()
        }
        
        return config
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: Config.defaultKey)
    }
    
}

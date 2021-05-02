//
//  DefaultConfig.swift
//  UIDisplayManager
//
//  Created by Daniel Fortesque on 30/04/21.
//

import Foundation

struct Config: Codable {
    public var configs: [UUID: Mode] = [:]
    
    private static let defaultKey = "defaultConfig"
    private static let defaults = UserDefaults(suiteName: "R779A64KR9.com.danxnu.displaymanager")!
    
    enum CodingKeys: String, CodingKey {
        case configs
    }
    
    static func getDefault() -> Config {
        guard let data = defaults.data(forKey: defaultKey) else {
            return Config()
        }
        
        guard let config = try? JSONDecoder().decode(Config.self, from: data) else {
            return Config()
        }
        
        return config
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        Config.defaults.set(data, forKey: Config.defaultKey)
    }
    
}

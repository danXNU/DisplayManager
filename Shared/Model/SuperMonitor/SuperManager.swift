//
//  Manager.swift
//  GHDisplayManager
//
//  Created by Daniel Bazzani on 24/05/22.
//

import Foundation

fileprivate let configUrl: URL = {
    var docs = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "R779A64KR9.com.danxnu.displaymanager")!
    docs.appendPathComponent("super-configs.json")
    print("🟢 URL: \(docs.path)")
    return docs
}()

class SuperManager: ObservableObject {
    
    @Published var configs: Set<SuperConfiguration> = []
    private let superAgent: SuperAgent = SuperAgent.init()
    
    init() {
        self.fetchConfigurations()
    }
    
    func searchAndApplyConfig() {
        if let config = self.getAppropriateConfig() {
            print("🟢 CONFIG FOUND!!")
            
            let rawConfig = config.rawRepresentation as? [Any]
            self.superAgent.applyConfig(rawConfig)
            NotificationCenter.default.post(name: .init(rawValue: "config-applied"), object: nil, userInfo: ["config": config])
        } else {
            print("🔴 NO VALID CONFIG FOUND")
        }
    }
    
    func saveCurrentConfig(name: String) {
        let displaysConfig = superAgent.getCurrentConfig() as! [Dictionary<String, Any>]
        
        var configMap: [UUID: MonitorConfig] = [:]
        
        for display in displaysConfig {
            let _r = display["rect"] as! Dictionary<String, Double>
            let rect = CGRect(x: _r["x"]!,
                              y: _r["y"]!,
                              width: _r["width"]!,
                              height: _r["height"]!)
            let isMain = display["isMain"] as! Bool
            
            let displayID = display["id"] as! CGDirectDisplayID
            let displayUUID = superAgent.getUUIDFromDisplayID(displayID)!
            
            let monitorConig = MonitorConfig(rect: rect, isMain: isMain)
            configMap[displayUUID] = monitorConig
        }
        
        let newConfig = SuperConfiguration(name: name, configMap: configMap)
        self.addConifg(newConfig)
    }
    
    func addConifg(_ config: SuperConfiguration) {
        self.configs.insert(config)
        self.saveConfigurations(self.configs)
    }
    
    func removeConfig(_ config: SuperConfiguration) {
        self.configs.remove(config)
        self.saveConfigurations(self.configs)
    }
    
    func saveConfigurations(_ configurations: Set<SuperConfiguration>) {
        guard let data = try? JSONEncoder().encode(configurations) else { return }
        if FileManager.default.fileExists(atPath: configUrl.path) {
            try? FileManager.default.removeItem(atPath: configUrl.path)
        }
        FileManager.default.createFile(atPath: configUrl.path, contents: data)
    }
    
    func fetchConfigurations() {
        guard let data = FileManager.default.contents(atPath: configUrl.path) else { return }
        do {
            let configs = try JSONDecoder().decode([SuperConfiguration].self, from: data)
            self.configs = Set(configs)
        } catch {
            fatalError("\(error)")
        }
    }
    
    func getAppropriateConfig() -> SuperConfiguration? {
        let displayManager = DisplayManager()
        let displaysIDs = Set(displayManager.getActiveMonitors().compactMap { displayManager.getUUIDFromDisplay($0) })
        
        var selectedConfig: SuperConfiguration?
        
        for config in configs {
            let configDisplays = config.displays
            
            var isAppropriate: Bool = true
            for display in configDisplays {
                if !displaysIDs.contains(display) {
                    isAppropriate = false
                    break
                }
            }
            
            if isAppropriate {
                selectedConfig = config
            }
        }
        
        return selectedConfig
    }
    
}

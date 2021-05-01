//
//  ContentView.swift
//  UIDisplayManager
//
//  Created by Daniel Fortesque on 29/04/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.monitors, id: \.number) { monitor in
                VStack {
                    Image(systemName: "display")
                        .font(.largeTitle)
                        .onHover { isHovered in
                            if isHovered {
                                show(monitor: monitor)
                            } else {
                                hide()
                            }
                        }
                    Text("Monitor \(monitor.number)")
                    
                    Picker("Resolution", selection: resolutionBinding(for: monitor)) {
                        let modes = monitor.getAvailableModes()
                        ForEach(modes, id: \.id) { mode in
                            Text(mode.string(style: .medium))
                                .tag(mode)
                        }
                    }
                    .frame(width: 250)
                    
                    Divider()
                }
                
            }
            
            VStack {
                HStack {
                    Text("Save config as default")
                    
                    Spacer()
                    Button("Save") {
                        viewModel.saveConfig()
                    }
                    .disabled(saveButtonDisabled)
                }
                
                HStack {
                    Text("Set config on startup")
                    Spacer()
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
                
                Button("Restore default") {
                    viewModel.restoreDefaults()
                }
                .disabled(isRestoreDefaultDisabled)
            }
        }
        .padding()
    }
    
    func show(monitor: Monitor) {
        guard let screen = NSScreen.screens.first(where: { screen in
            let key = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
            return screen.deviceDescription[key] as? UInt32 == monitor.number
        }) else {
            return
        }
        
        hide()
        
        let vc = NSHostingController(rootView: PlaceholderView(monitor: monitor))
        vc.view.frame = screen.frame
        vc.view.layer?.backgroundColor = .clear
        
        let newWindow = NSPanel(contentViewController: vc)
        newWindow.styleMask =  NSWindow.StyleMask.hudWindow
        newWindow.setFrameOrigin(screen.visibleFrame.origin)
        newWindow.isMovable = false
        newWindow.isMovableByWindowBackground = false
        
        viewModel.presentedWindow = NSWindowController(window: newWindow)
        viewModel.presentedWindow?.showWindow(nil)
        
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
    }
    
    func hide() {
        viewModel.dismissPlaceholder()        
    }
    
    func resolutionBinding(for monitor: Monitor) -> Binding<Mode> {
        return Binding {
            return monitor.currentMode
        } set: { newValue in
            monitor.setNewMode(mode: newValue)
        }
    }
    
    var isRestoreDefaultDisabled: Bool {
        if viewModel.defaultConfig.configs.isEmpty { return true }
        return !viewModel.hasChanged
    }
    
    var saveButtonDisabled: Bool {
        if viewModel.defaultConfig.configs.isEmpty { return false }
        return !viewModel.hasChanged
    }
}


struct PlaceholderView: View {
    var monitor: Monitor
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.4)
            
            VStack(spacing: 5) {
                Text("\(monitor.number)")
                    .font(.system(size: 200))
                
                Text("\(monitor.currentMode.string(style: .min))")
                    .font(.system(size: 40))
            }
        }
    }
}

//
//  ContentView.swift
//  UIDisplayManager
//
//  Created by Daniel Fortesque on 29/04/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    @State var isHelpScreenShowing: Bool = false
    
    @State var isStatusBarItem: Bool = false
    
    var body: some View {
        VStack {
            ForEach(viewModel.monitors, id: \.number) { monitor in
                VStack {
                    Image(systemName: "display")
                        .font(.largeTitle)
                        .onHover { isHovered in
                            if isStatusBarItem { return }
                            if isHovered {
                                viewModel.show(monitor: monitor)
                            } else {
                                viewModel.dismissPlaceholder()
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
                .frame(height: 100)
                
            }
            
            VStack {
                if !isStatusBarItem {
                    HStack {
                        Text("Save config as default")
                        
                        Spacer()
                        Button("Save") {
                            viewModel.saveConfig()
                        }
                        .disabled(saveButtonDisabled)
                    }
                    
                    Button("Restore default") {
                        viewModel.restoreDefaults()
                    }
                    .disabled(isRestoreDefaultDisabled)
                    
                    Divider()
                    
                    HStack {
                        Text("Apply config on startup")
                        Image(systemName: "questionmark.circle.fill")
                            .onTapGesture {
                                isHelpScreenShowing.toggle()
                            }
                            .popover(isPresented: $isHelpScreenShowing) {
                                VStack(alignment: .leading) {
                                    Text("Set the default resolution on startup.")
                                        .bold()
                                    Text("")
                                    Text("If you are using multiple 4K monitors with a M1 Mac and DisplayLink,\nsave the configuration on DisplayManager and activate this feature. \nThis will auto-set all the monitors resolution to your config on user login.")
                                }
                                .padding()
                            }
                        
                        Spacer()
                        
                        Toggle("", isOn: loginAgentBinding)
                            .toggleStyle(SwitchToggleStyle())
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text("Open status bar item on login")
                        
                        Spacer()
                        
                        Toggle("", isOn: loginAgentUIBinding)
                            .toggleStyle(SwitchToggleStyle())
                            .labelsHidden()
                    }
                } else {
                    Button("Quit") {
                        NSApp.terminate(nil)
                    }
                }
                
            }
        }
        .padding()
    }
    
    var loginAgentBinding: Binding<Bool> {
        Binding {
            viewModel.loginServiceActive
        } set: { active in
            viewModel.loginServiceActive = active
            if active {
                viewModel.activateOnStartup()
            } else {
                viewModel.activateOnStartup(activate: false)
            }
        }
    }
    
    var loginAgentUIBinding: Binding<Bool> {
        Binding {
            viewModel.statusBarAgentActive
        } set: { active in
            viewModel.statusBarAgentActive = active
            if active {
                viewModel.activateAgentOnStartup()
            } else {
                viewModel.activateAgentOnStartup(activate: false)
            }
        }
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

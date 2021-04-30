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
        ScrollView {
            VStack {
//                Button("Aggiorna") {
//                    viewModel.update()
//                }
                
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
                        
                        Picker("Risoluzione", selection: resolutionBinding(for: monitor)) {
//                            let modes = viewModel.getModes(for: monitor)
//                            ForEach(modes, id: \.self) { mode in
//                                Text(mode)
//                            }
                            
                            let modes = monitor.getAvailableModes()
                            ForEach(modes, id: \.id) { mode in
                                Text(mode.string(style: .medium))
                                    .tag(mode)
                            }
                        }
                        .frame(width: 250)
                                                
                        Divider()
                    }
                    .padding()
                }
            }
        }
        
    }
    
    func show(monitor: Monitor) {
        guard let screen = NSScreen.screens.first(where: { screen in
            let key = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
            return screen.deviceDescription[key] as? UInt32 == monitor.number
        }) else {
            return
        }
        
        let frame = screen.frame
        let vc = NSHostingController(rootView: Color.blue.opacity(0.5))
        vc.view.frame = frame
        vc.view.resignFirstResponder()
        vc.view.layer?.backgroundColor = .clear
        
//        let newWindow = NSWindow(contentViewController: vc)
        let newWindow = NSPanel(contentViewController: vc)
        newWindow.styleMask =  NSWindow.StyleMask.hudWindow
        newWindow.setFrameOrigin(screen.visibleFrame.origin)
        newWindow.isMovable = false
        newWindow.isMovableByWindowBackground = false
        
        viewModel.presentedWindow = NSWindowController(window: newWindow)
        viewModel.presentedWindow?.showWindow(nil)
        viewModel.presentedWindow?.resignFirstResponder()
        
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        NSApp.keyWindow?.level = .statusBar
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class PlaceHolderWindow: NSWindow {
    
}

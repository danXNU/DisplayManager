//
//  UIDisplayManagerApp.swift
//  UIDisplayManager
//
//  Created by Daniel Fortesque on 29/04/21.
//

import SwiftUI

@main
struct UIDisplayManagerApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView()
                
                HStack(spacing: 0) {
                    Text("DisplayManager by Daniel (@danxnu) - ")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    
                    Text("GitHub")
                        .underline()
                        .bold()
                        .foregroundColor(.blue)
                        .font(.caption)
                        .onTapGesture {
                            let url = URL(string: "https://www.github.com/danxnu")!
                            NSWorkspace.shared.open(url)
                        }
                }
            }
            .padding(.bottom)
            .frame(maxWidth: 350)
        }
    }
}

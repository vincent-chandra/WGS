//
//  TechnicalTestWGSApp.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 19/06/25.
//

import SwiftUI

@main
struct TechnicalTestWGSApp: App {
    @StateObject var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.environmentObject(networkMonitor)
    }
}

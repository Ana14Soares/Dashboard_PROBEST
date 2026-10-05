// App/SteamAnalyticsApp.swift
import SwiftUI

@main
struct dashboardApp: App {
    @State private var app = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(app)
                .task { app.carregar() }
        }
        #if os(macOS)
        .defaultSize(width: 1440, height: 900)
        .windowResizability(.contentMinSize)
        #endif
    }
}

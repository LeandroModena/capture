//
//  CaptureIdApp.swift
//  CaptureId
//
//  Created by Leandro Modena on 10/05/25.
//

import SwiftUI

@main
struct CaptureIdApp: App {
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                HomeView()
                    .environment(\.navigation, coordinator)
                    .navigationDestination(for: HomeRoute.self) { route in
                        switch route {
                        case .capture:
                            CaptureView()
                                .environment(\.navigation, coordinator)
                        case .captureCamera:
                            CameraCaptureView()
                                .environment(\.navigation, coordinator)
                        case .consult:
                            ConsultView()
                        case .match:
                            MatchView()
                                .environment(\.navigation, coordinator)
                        case .settings:
                            SettingsView()
                        case .photoList:
                            PhotosGridView()
                        }
                    }
            }
        }
    }
}

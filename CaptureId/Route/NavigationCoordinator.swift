//
//  NavigationCoordinator.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI

final class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: HomeRoute) {
        self.path.append(route)
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func reset() {
        path = NavigationPath()
    }
}



private struct NavigationCoordinatorKey: EnvironmentKey {
    static let defaultValue = NavigationCoordinator()
}

extension EnvironmentValues {
    var navigation: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
}

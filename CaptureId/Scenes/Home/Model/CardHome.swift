//
//  CardHome.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUICore

struct CardHome: Identifiable {
    let id: UUID = UUID()
    let title: String
    let icon: String
    let color: Color
    let route: HomeRoute
}

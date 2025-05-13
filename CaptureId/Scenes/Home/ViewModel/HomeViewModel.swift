//
//  HomeViewModel.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    
    let cards: [CardHome] = [
        CardHome(title: "Captura Facial", icon: "faceid", color: .blue, route: .capture),
        CardHome(title: "Consulta", icon: "doc.text.magnifyingglass", color: .green, route: .consult),
        CardHome(title: "Matching", icon: "person.2.square.stack", color: .yellow, route: .match),
        CardHome(title: "Configurações", icon: "gearshape", color: .red, route: .settings)
    ]
}

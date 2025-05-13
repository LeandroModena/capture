//
//  MatchView.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUICore
import SwiftUI

struct MatchView: View {
    @Environment(\.navigation) private var navigation
    
    var body: some View {
        VStack {
            Button(action: {
                navigation.navigate(to: .photoList)
            }) {
                Text("Match Local")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

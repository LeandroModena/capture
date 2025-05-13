//
//  CaptureView.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI

struct CaptureView: View {

    @State private var identifier: String = ""
    @StateObject private var viewModel = CaptureViewModel()
    @Environment(\.navigation) private var navigation

    var body: some View {
            VStack {
                FloatingLabelTextField(
                    placeholder: "Identificador",
                    text: $identifier
                )
                .padding()
                
                Spacer()
                
                Button(action: {
                    navigation.navigate(to: .captureCamera)
                }) {
                    Text("Iniciar captura")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Captura facial")
        }
}

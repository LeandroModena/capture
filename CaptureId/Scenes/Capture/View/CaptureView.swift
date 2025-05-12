//
//  CaptureView.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI

struct CaptureView: View {
    
    @State private var identifier: String = ""
    
    var body: some View {
        VStack {
            FloatingLabelTextField(
                placeholder: "Identificador",
                text: $identifier
            )
            .padding()
            
            Spacer()
            
            Button(action: {
                print("Iniciar captura para: \(identifier)")
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

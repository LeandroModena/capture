//
//  CameraView.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI

struct CameraCaptureView: View {
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.navigation) private var navigation

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraCapturePreview(session: viewModel.session)
                .ignoresSafeArea(edges: [.bottom])

            Button(action: {
                viewModel.captureImage()
            }) {
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .padding(.bottom, 32)
            }
        }
        .navigationBarTitle("Captura", displayMode: .inline)
        .onChange(of: viewModel.shouldDismiss) {
            navigation.goBack()
        }
        .onAppear {
            viewModel.configure()
        }
        .onDisappear {
            viewModel.stopSession()
        }

    }
}


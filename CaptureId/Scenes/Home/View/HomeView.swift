//
//  HomeView.swift
//  CaptureId
//
//  Created by Leandro Modena on 10/05/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.cards) { card in
                        VStack(spacing: 16) {
                            Image(systemName: card.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            Text(card.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .padding()
                        .background(card.color)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .onTapGesture {
                            viewModel.navigate(to: card.route)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .capture:
                    CaptureView()
                case .consult:
                    ConsultView()
                case .match:
                    MatchView()
                case .settings:
                    CameraCaptureView()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

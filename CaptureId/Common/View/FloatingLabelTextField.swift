//
//  FloatingLabelTextField.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI

struct FloatingLabelTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var shouldFloatLabel: Bool {
        isFocused || !text.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .offset(y: shouldFloatLabel ? -28 : 0)
                    .scaleEffect(shouldFloatLabel ? 0.8 : 1, anchor: .leading)
                    .padding(.top, 6)
                    .animation(.easeOut(duration: 0.2), value: shouldFloatLabel)

                Group {
                    if isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                    }
                }
                .padding(.top, shouldFloatLabel ? 12 : 0)
                .animation(.easeOut(duration: 0.2), value: shouldFloatLabel)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorMessage != nil ? Color.red : Color.gray, lineWidth: 1)
            )

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .animation(.easeOut(duration: 0.2), value: text)
    }
}

//
//  TilesButton.swift
//  Stravo
//
//  Created by Bob Voorneveld on 07/01/2023.
//

import SwiftUI

struct TilesButton: View {
    @Binding var loading: Bool
    
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                if loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
                Text("Tiles")
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.indigo.opacity(0.7))
            .cornerRadius(5)
        }
    }
}

struct TilesButton_Previews: PreviewProvider {
    static var previews: some View {
        TilesButton(loading: .constant(false)) {
            print("pressed")
        }
    }
}

//
//  MainView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            TilesView()
                .tabItem {
                    Label("Tiles", systemImage: "checkerboard.rectangle")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

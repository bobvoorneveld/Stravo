//
//  MainView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm: ViewModel

    var body: some View {
        TabView {
            TilesView(vm: .init(userStore: vm.userStore))
                .tabItem {
                    Label("Tiles", systemImage: "checkerboard.rectangle")
                }
        }
        .ignoresSafeArea()
    }
    
    class ViewModel: ObservableObject {
        var userStore: UserStore
        
        init(userStore: UserStore) {
            self.userStore = userStore
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

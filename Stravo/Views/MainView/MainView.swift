//
//  MainView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm: ViewModel

    @State private var activeTab = 0

    var body: some View {
        TabView(selection: $activeTab) {
            TilesNavigationView(vm: .init(userStore: vm.userStore))
                .tag(0)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            Text("Test")
                .tag(1)
                .tabItem {
                    Text("Route")
                }
        }
        .tint(.indigo)
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

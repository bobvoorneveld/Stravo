//
//  TilesNavigationView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import SwiftUI


struct TilesNavigationView: View {
    @StateObject var vm: ViewModel

    var body: some View {
        NavigationStack {
            Group{
                TilesView(vm: .init(userStore: vm.userStore))
                    .navigationTitle("Map")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SettingsView(vm: .init(userStore: vm.userStore))) {
                                Label("Settings", systemImage: "gear")
                            }
                        }
                    }
            }
            .navigationDestination(for: String.self) { string in
                Text(string)
                    .navigationTitle("Settings")
            }
        }

    }
    
    class ViewModel: ObservableObject {
        let userStore: UserStore
        
        init(userStore: UserStore) {
            self.userStore = userStore
        }
    }
}

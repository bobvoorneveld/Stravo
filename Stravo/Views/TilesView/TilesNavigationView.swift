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
                            Button {
                                vm.synchronizeTiles()
                            } label: {
                                Label("Sync", systemImage: "arrow.clockwise")
                                    .rotationEffect(.degrees(vm.isRotating))
                                    .animation(
                                        vm.isRotating == 0 ? Animation.default :
                                        Animation.linear(duration: 1)
                                        .speed(0.5)
                                        .repeatForever(autoreverses: false),
                                        value: vm.isRotating
                                    )
                            }
                        }

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
        @Published var isRotating = 0.0
        let userStore: UserStore
        
        init(userStore: UserStore) {
            self.userStore = userStore
        }
        
        func synchronizeTiles() {
            isRotating = isRotating > 0 ? 0 : 360
        }
    }
}

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

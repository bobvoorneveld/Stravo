//
//  TilesView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI
import MapKit
import CoreLocation
import KeychainAccess

struct TilesView: View {
    @StateObject var vm: ViewModel
    @Environment(\.scenePhase) var scenePhase

    init(vm: ViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            MapView(vm: vm.mapVM)

            HStack {
                Spacer()

                VStack(alignment: .trailing) {
                    Spacer()
                    
                    if vm.showLocationButton {
                        Button {
                            vm.trackUserLocation()
                        } label: {
                            Image(systemName: "location")
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.indigo.opacity(0.7))
                                .cornerRadius(5)
                        }
                        .padding(.bottom)
                    }

                    TilesButton(loading: $vm.loadingTiles) {
                        vm.toggleTiles()
                    }
                    .padding(.bottom)
                }
                .padding(.trailing)
            }
            
            VStack {
                Spacer()
                
                Button {
                    vm.toggleRecording()
                } label: {
                    Text(vm.recordButtonText)
                        .foregroundColor(.white)
                        .padding()
                        .background(.indigo.opacity(0.7))
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            vm.scenePhase = newPhase
        }
    }
}

struct TilesView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationStack {
                TilesView(vm: .init(userStore: .init()))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

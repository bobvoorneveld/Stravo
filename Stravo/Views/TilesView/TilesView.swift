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

    var body: some View {
        NavigationView {
            ZStack {
                MapView(vm: vm.mapVM)
                    .task {
                        await vm.loadTiles()
                    }

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

                        Button {
                            vm.toggleTiles()
                        } label: {
                            Text("Tiles")
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.indigo.opacity(0.7))
                                .cornerRadius(5)
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
                        Text("Record")
                            .foregroundColor(.white)
                            .padding()
                            .background(.indigo.opacity(0.7))
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                    }
                }
            }
        }
    }
}

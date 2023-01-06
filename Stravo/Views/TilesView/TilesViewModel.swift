//
//  TilesViewModel.swift
//  Stravo
//
//  Created by Bob Voorneveld on 04/01/2023.
//

import SwiftUI
import MapKit
import Combine
import Polyline


extension TilesView {
    @MainActor
    class ViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
        @Published var showLocationButton = true
        @Published var showTilesButton = true
        @Published var recordButtonText = "Record"

        let mapVM = MapView.ViewModel()

        private let userStore: UserStore
        private let routeManager = RouteManager()
        private let tileManager: TileManager

        private var subscriptions = Set<AnyCancellable>()
        
        init(userStore: UserStore) {
            self.userStore = userStore
            self.tileManager = TileManager(userStore: userStore)
            super.init()
            
            routeManager.polylinePublisher()
                .removeDuplicates(by: { $0.encodedPolyline == $1.encodedPolyline })
                .sink {
                    print($0.encodedPolyline)
                }
                .store(in: &subscriptions)
            
            routeManager.statusPublisher()
                .removeDuplicates()
                .map {
                    switch $0 {
                    case .initialized, .stopped: return "Record"
                    case .paused: return "Continue"
                    case .monitoring: return "Pause"
                    }
                }
                .assign(to: &$recordButtonText)
            
            mapVM.$userTrackingMode.removeDuplicates()
                .map { $0 != .follow }
                .assign(to: &$showLocationButton)
            
            mapVM.$showTiles
                .assign(to: &$showTilesButton)
        }
        
                        
        func toggleRecording() {
            if routeManager.status != .monitoring {
                routeManager.startMonitoring()
            } else {
                routeManager.stopMonitoring()
            }
        }
        
        func trackUserLocation() {
            mapVM.userTrackingMode = .follow
        }
        
        func toggleTiles() {
            mapVM.showTiles.toggle()
        }
                
        func loadTiles() async {
            do {
                mapVM.tiles = try await tileManager.loadTiles()
            } catch {
                print(error)
            }
        }
    }
}

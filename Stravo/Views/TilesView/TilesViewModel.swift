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
        @Published var loadingTiles = false
        
        let mapVM = MapView.ViewModel()

        private let scenePhaseSubject = PassthroughSubject<ScenePhase, Never>()
        var scenePhase: ScenePhase = .background {
            didSet {
                scenePhaseSubject.send(scenePhase)
            }
        }

        private let userStore: UserStore
        private let routeManager = RouteManager()
        private let tileManager: TileManager

        private var subscriptions = Set<AnyCancellable>()
        
        init(userStore: UserStore) {
            self.userStore = userStore
            self.tileManager = TileManager(userStore: userStore)
            super.init()
            
            routeManager.coordinatePublisher()
                .filter { !$0.isEmpty }
                .removeDuplicates() // Do not fetch if there aren't any new coordinates
                .combineLatest(
                    scenePhaseSubject
                        .eraseToAnyPublisher()
                        .removeDuplicates()
                )
                .filter { $0.1 == .active } // Only fire if scene is active, no background fetches
                .throttle(for: 10, scheduler: RunLoop.main, latest: true) // only fetch every 10 seconds
                .sink(receiveValue: { [unowned self] coordinates, _ in
                    fetchNewTiles(coordinates: coordinates)
                })
                .store(in: &subscriptions)
            
            routeManager.trackPublisher()
                .assign(to: &mapVM.$track)
            
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
            
            Task {
                loadingTiles = true
                await loadTiles()
                loadingTiles = false
                mapVM.showTiles = true
            }
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
                mapVM.currentTilesOverlay = try await tileManager.loadTiles()
            } catch {
                print(error)
            }
        }
        
        func fetchNewTiles(coordinates: [CLLocationCoordinate2D]) {
            Task {
                print("fetching new tiles")
                do {
                    let tiles = try await tileManager.checkForNewTiles(coordinates: coordinates)
                    mapVM.newTilesOverlay = tiles
                } catch {
                    print(error)
                }
            }
        }
    }
}

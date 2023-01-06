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
        @Published var tiles: [MKMultiPolygon]?
        @Published var track: MKPolyline?
        @Published var showTiles: Bool = false
        @Published var userTrackingMode: MKUserTrackingMode = .none

        var region: MKCoordinateRegion?

        private let userStore: UserStore
        private let routeManager = RouteManager()

        private var subscriptions = Set<AnyCancellable>()
        
        init(userStore: UserStore) {
            self.userStore = userStore
            super.init()
            
            routeManager.polylinePublisher()
                .removeDuplicates(by: { $0.encodedPolyline == $1.encodedPolyline })
                .sink {
                    print($0.encodedPolyline)
                }
                .store(in: &subscriptions)
        }
        
                        
        func toggleRecording() {
            if routeManager.status == .initialized || routeManager.status == .paused {
                routeManager.startMonitoring()
            } else {
                routeManager.stopMonitoring()
            }
        }
                
        func loadTiles() async {
            var request = URLRequest(url: URL(string: "http://dbd1-2a02-a446-ae5d-1-8505-d6f6-5c81-11bd.ngrok.io/activities/tiles")!)
            request.setValue("Bearer \(userStore.token!)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode != 200 {
                    throw StravoCloudError.invalidResponse
                }
                
                let decoder = MKGeoJSONDecoder()
                let geojson = try decoder.decode(data)
                
                if let polygons = geojson as? [MKMultiPolygon] {
                    await MainActor.run {
                        self.tiles = polygons
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

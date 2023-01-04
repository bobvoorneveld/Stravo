//
//  TilesViewModel.swift
//  Stravo
//
//  Created by Bob Voorneveld on 04/01/2023.
//

import SwiftUI
import MapKit


extension TilesView {
    @MainActor
    class ViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
        @Published var center: CLLocationCoordinate2D?
        @Published var tiles: [MKMultiPolygon]?
        @Published var track: MKPolyline?
        @Published var showTiles: Bool = false

        var region: MKCoordinateRegion?
        var shouldUpdateView: Bool = true

        private let manager = CLLocationManager()
        private let userStore: UserStore
        
        private var isMonitoring = false
        
        private var userLocations = [CLLocation]()

        init(userStore: UserStore) {
            self.userStore = userStore
            super.init()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.allowsBackgroundLocationUpdates = true
            manager.requestAlwaysAuthorization()
        }
        
        func add(locations: [CLLocation]) async {
            userLocations.append(contentsOf: locations)
            let coordinates = userLocations.map { $0.coordinate }
            track = MKPolyline(coordinates: coordinates, count: coordinates.count)
        }
        
        func setCenter() {
            center = userLocations.last.map { $0.coordinate }
        }
        
        func toggleRecording() {
            if isMonitoring {
                manager.stopUpdatingLocation()
                manager.showsBackgroundLocationIndicator = false
                userLocations = []
                track = nil
            } else {
                manager.showsBackgroundLocationIndicator = true
                manager.startUpdatingLocation()
            }
            isMonitoring.toggle()
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            Task {
                await add(locations: locations)
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

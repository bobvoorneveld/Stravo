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
                MapView(vm: vm)
                    .task {
                        await vm.loadTiles()
                    }

                HStack {
                    Spacer()

                    VStack(alignment: .trailing) {
                        Spacer()
                        
                        Button {
                            vm.setCenter()
                        } label: {
                            Image(systemName: "location")
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.indigo.opacity(0.7))
                                .cornerRadius(5)
                        }
                        .padding(.bottom)

                        Button {
                            vm.showTiles.toggle()
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
            }
        }
    }
    
    @MainActor
    class ViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
        @Published var center: CLLocationCoordinate2D?
        @Published var tiles: [MKMultiPolygon]?
        @Published var showTiles: Bool = false

        var region: MKCoordinateRegion?
        var shouldUpdateView: Bool = true

        private let manager = CLLocationManager()
        private let userStore: UserStore
        
        private var userLocations = [CLLocation]()

        init(userStore: UserStore) {
            self.userStore = userStore
            super.init()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
        }
        
        func add(locations: [CLLocation]) async {
            userLocations.append(contentsOf: locations)
        }
        
        func setCenter() {
            center = userLocations.last.map { $0.coordinate }
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

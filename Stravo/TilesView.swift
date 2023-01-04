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
                Text(vm.region.debugDescription)
            }
        }
        .ignoresSafeArea()
    }
    
    @MainActor
    class ViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
        @Published var center: CLLocationCoordinate2D?
        @Published var tiles: MKMultiPolygon?
        var region: MKCoordinateRegion?
        var shouldUpdateView: Bool = true

        private let manager = CLLocationManager()
        private let userStore: UserStore

        init(userStore: UserStore) {
            self.userStore = userStore
            super.init()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            Task { await MainActor.run { center = locations.last.map { $0.coordinate } } }            
            manager.stopUpdatingLocation()
        }
        
        func loadTiles() async {
            var request = URLRequest(url: URL(string: "http://d1de-2a02-a446-ae5d-1-a580-e4e6-85a-e141.ngrok.io/activities/tiles")!)
            request.setValue("Bearer \(userStore.token!)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode != 200 {
                    print(urlResponse.statusCode)
                    throw StravoCloudError.invalidResponse
                }
                let polygons = try JSONDecoder().decode(Polygons.self, from: data)
                let regex = #/Polygon\(\((?<coords>(((-?\d+.\d+) (-?\d+.\d+))(, )?)+)/#
                
                var mapPolys = [MKPolygon]()
                
                for poly in polygons.polygons {
                    guard let match = poly.firstMatch(of: regex) else {
                        continue
                    }
                    let coords = match.coords.split(separator: ", ")
                    var locationCoords = [CLLocationCoordinate2D]()
                    for coord in coords {
                        let latlng = coord.split(separator: " ")
                        locationCoords.append(CLLocationCoordinate2D(latitude: Double(latlng[1])!, longitude: Double(latlng[0])!))
                    }
                    
                    mapPolys.append(MKPolygon(coordinates: locationCoords, count: locationCoords.count))
                }
                
                MKMultiPolygon(mapPolys)
                
                await MainActor.run {
                    self.tiles = MKMultiPolygon(mapPolys)
                }
            } catch {
                print(error)
            }
        }
    }
    
    struct Polygons: Decodable {
        let polygons: [String]
    }
}


//struct TilesView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}


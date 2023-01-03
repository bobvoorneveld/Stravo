//
//  TilesView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct TilesView: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                MapView(vm: vm)
                Text(vm.region.debugDescription)
            }
        }
        .ignoresSafeArea()
    }
}

struct TilesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

class ViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var region: MKCoordinateRegion?
    @Published var center: CLLocationCoordinate2D?
    var shouldUpdateView: Bool = true

    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            center = $0.coordinate
        }
        manager.stopUpdatingLocation()
    }
}

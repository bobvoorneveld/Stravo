//
//  TilesView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI
import CoreLocation

struct TilesView: View {
    @StateObject var manager = LocationManager()
   
    var body: some View {
        NavigationView {
            Text("Map")
        }
        .ignoresSafeArea()
    }
}

struct TilesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
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
            print($0)
        }
    }
}

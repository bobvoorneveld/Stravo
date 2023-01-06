//
//  MapViewModel.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import Foundation
import SwiftUI
import MapKit


extension MapView {
    class ViewModel: ObservableObject {
        @Published var tiles: [MKMultiPolygon]?
        @Published var track: MKPolyline?
        @Published var showTiles: Bool = false
        @Published var userTrackingMode: MKUserTrackingMode = .none

        var region: MKCoordinateRegion?
    }
}

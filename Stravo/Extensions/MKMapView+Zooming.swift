//
//  MKMapView+Zooming.swift
//  Stravo
//
//  Created by Bob Voorneveld on 04/01/2023.
//

import MapKit

public extension MKMapView {

    func metersToPoints(meters: Double) -> Double {

        let deltaPoints = 500.0

        let point1 = CGPoint(x: 0, y: 0)
        let coordinate1 = convert(point1, toCoordinateFrom: self)
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)

        let point2 = CGPoint(x: 0, y: deltaPoints)
        let coordinate2 = convert(point2, toCoordinateFrom: self)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)

        let deltaMeters = location1.distance(from: location2)

        let pointsPerMeter = deltaPoints / deltaMeters

        return meters * pointsPerMeter
    }
}

//
//  RouteManager.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import Foundation
import CoreLocation
import Combine
import Polyline


class RouteManager: NSObject {
    private let polylineSubject = PassthroughSubject<Polyline, Never>()

    enum Status {
        case initialized, monitoring, paused, stopped
    }
    var status: Status {
        statusSubject.value
    }
    private let statusSubject = CurrentValueSubject<Status, Never>(.initialized)
    
    private let locationManger = CLLocationManager()
    
    private var locations = [CLLocation]() {
        didSet {
            updateCoordinates()
        }
    }
    private var coordinates = [CLLocationCoordinate2D]() {
        didSet {
            createPolyline()
        }
    }
    
    override init() {
        super.init()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.allowsBackgroundLocationUpdates = true

        if locationManger.authorizationStatus == .notDetermined {
            locationManger.requestAlwaysAuthorization()
        }
    }
    
    func polylinePublisher() -> AnyPublisher<Polyline, Never> {
        polylineSubject.eraseToAnyPublisher()
    }
    
    func statusPublisher() -> AnyPublisher<Status, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    func startMonitoring() {
        locationManger.startUpdatingLocation()
        locationManger.showsBackgroundLocationIndicator = true
        statusSubject.send(.monitoring)
    }
    
    func pauseMonitoring() {
        locationManger.stopUpdatingLocation()
        locationManger.showsBackgroundLocationIndicator = false
        statusSubject.send(.paused)
    }
    
    func stopMonitoring() {
        pauseMonitoring()
        locations = []
        statusSubject.send(.stopped)
    }
    
    private func updateCoordinates() {
        guard locations.count > 1 else {
            coordinates = locations.map { $0.coordinate }
            return
        }

        var coords = [locations[0].coordinate]
        
        let epsilon = 0.00001
        for location in locations[1...] {
            if abs(coords.last!.latitude - location.coordinate.latitude) >= epsilon && abs(coords.last!.longitude - location.coordinate.longitude) >= epsilon {
                coords.append(location.coordinate)
            }
        }
        coordinates = coords
    }
    
    private func createPolyline() {
        polylineSubject.send(Polyline(coordinates: coordinates))
    }
}

extension RouteManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
    }
}

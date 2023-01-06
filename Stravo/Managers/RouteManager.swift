//
//  RouteManager.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import Foundation
import CoreLocation
import Combine
import MapKit


class RouteManager: NSObject {
    private let coordinateSubject = CurrentValueSubject<[CLLocationCoordinate2D], Never>([])

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
    
    override init() {
        super.init()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.allowsBackgroundLocationUpdates = true

        if locationManger.authorizationStatus == .notDetermined {
            locationManger.requestAlwaysAuthorization()
        }
    }
    
    func coordinatePublisher() -> AnyPublisher<[CLLocationCoordinate2D], Never> {
        coordinateSubject.eraseToAnyPublisher().removeDuplicates().eraseToAnyPublisher()
    }
    
    func trackPublisher() -> AnyPublisher<MKPolyline?, Never> {
        coordinateSubject.eraseToAnyPublisher().removeDuplicates()
            .map { MKPolyline(coordinates: $0, count: $0.count) }
            .eraseToAnyPublisher()
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
            coordinateSubject.send(locations.map { $0.coordinate })
            return
        }

        var coords = [locations[0].coordinate]
        
        for location in locations[1...] {
            if coords.last != location.coordinate {
                coords.append(location.coordinate)
            }
        }
        coordinateSubject.send(coords)
    }
}

extension RouteManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        let epsilon = 0.00001
        if abs(lhs.latitude - rhs.latitude) <= epsilon && abs(lhs.longitude - rhs.longitude) <= epsilon {
            return true
        }
        return false
    }
}

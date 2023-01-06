//
//  CLLocationManagerPublisher.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import Foundation
import CoreLocation
import Combine


class LocationManager: NSObject {
    private let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let locationSubject = PassthroughSubject<[CLLocation], Never>()
    private let manager: CLLocationManager

    init(manager: CLLocationManager) {
        self.manager = manager
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true

        if manager.authorizationStatus == .notDetermined {
            manager.requestAlwaysAuthorization()
        }
    }

    func authorizationPublisher() -> AnyPublisher<CLAuthorizationStatus, Never> {
        Just(manager.authorizationStatus)
            .merge(with: authorizationSubject.compactMap { $0 })
            .eraseToAnyPublisher()
    }
    
    func locationPublisher() -> AnyPublisher<[CLLocation], Never> {
        return locationSubject.eraseToAnyPublisher()
    }
    
    func startMonitoring() {
        manager.startUpdatingLocation()
        manager.showsBackgroundLocationIndicator = true
    }
    
    func stopMonitoring() {
        manager.stopUpdatingLocation()
        manager.showsBackgroundLocationIndicator = false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationSubject.send(manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations)
    }
}

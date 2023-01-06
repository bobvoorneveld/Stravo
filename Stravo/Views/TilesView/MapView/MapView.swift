//
//  MapView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var vm: ViewModel
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.showsUserLocation = true
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = context.coordinator
        context.coordinator.colorScheme = colorScheme
        if view.userTrackingMode != vm.userTrackingMode {
            context.coordinator.pendingRegionChange = true
            view.userTrackingMode = vm.userTrackingMode
        }

        guard context.coordinator.shouldUpdateView else {
            context.coordinator.shouldUpdateView = true
            return
        }

        addOverlays(view)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(vm)
    }

    func addOverlays(_ view: MKMapView) {
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        
        if vm.showTiles, let tiles = vm.currentTilesOverlay {
            view.addOverlays(tiles)
        }
        
        if let tiles = vm.newTilesOverlay {
            view.addOverlays(tiles)
        }
        
        if let track = vm.track {
            view.addOverlay(track)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let vm: ViewModel
        var pendingRegionChange = false
        var shouldUpdateView = true
        var colorScheme: ColorScheme = .light
        
        init(_ vm: ViewModel) {
            self.vm = vm
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let overlay = overlay as? MKMultiPolygon {
                let renderer = ZoomingMultiPolygonRenderer(overlay: overlay, mapView: mapView, polylineWidth: 10)
                let color = colorScheme == .light ? UIColor.systemIndigo : UIColor.white
                renderer.fillColor = color.withAlphaComponent(0.2)
                renderer.strokeColor = color.withAlphaComponent(0.6)
                return renderer
            } else if let overlay = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.lineWidth = 2.0
                renderer.strokeColor = UIColor.systemIndigo.withAlphaComponent(0.8)
                return renderer
            } else if let overlay = overlay as? MKPolygon {
                let renderer = ZoomingPolygonRenderer(overlay: overlay, mapView: mapView, polylineWidth: 10)
                renderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.4)
                renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.6)
                return renderer
            }
            fatalError("Unknown overlay \(overlay)")
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if mapView.userTrackingMode != .none && !pendingRegionChange {
                mapView.userTrackingMode = .none
                Task {
                    await MainActor.run { vm.userTrackingMode = .none }
                }
            }
            pendingRegionChange = false
        }
            
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            shouldUpdateView = false
            Task { await MainActor.run {
                vm.region = mapView.region
            }}
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if mapView.userTrackingMode != .none {
                pendingRegionChange = true
                mapView.setCenter(userLocation.location!.coordinate, animated: true)
            }
        }
    }
}

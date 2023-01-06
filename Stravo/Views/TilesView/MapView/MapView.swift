//
//  MapView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var vm: TilesView.ViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.showsUserLocation = true
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = context.coordinator
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
        
        if vm.showTiles, let tiles = vm.tiles {
            view.addOverlays(tiles)
        }
        
        if let track = vm.track {
            view.addOverlay(track)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let vm: TilesView.ViewModel
        var pendingRegionChange = false
        var shouldUpdateView = true
        
        init(_ vm: TilesView.ViewModel) {
            self.vm = vm
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let overlay = overlay as? MKMultiPolygon {
                let renderer = ZoomingMultiPolygonRenderer(overlay: overlay, mapView: mapView, polylineWidth: 10)
                renderer.fillColor = UIColor.systemIndigo.withAlphaComponent(0.4)
                renderer.strokeColor = UIColor.systemIndigo.withAlphaComponent(0.6)
                return renderer
            } else if let overlay = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.lineWidth = 2.0
                renderer.strokeColor = UIColor.systemIndigo.withAlphaComponent(0.8)
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

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
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.showsUserLocation = true
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        guard vm.shouldUpdateView else {
            vm.shouldUpdateView = true
            return
        }
        if let center = vm.center {
            print("updating")
            view.setCenter(center, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(vm)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let vm: ViewModel
        
        init(_ vm: ViewModel) {
            self.vm = vm
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.8)
            return renderer
        }
            
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            vm.shouldUpdateView = false
            vm.region = mapView.region
        }
    }
}

//private extension MapView {
//    func addRoute(to view: MKMapView) {
//        if !view.overlays.isEmpty {
//            view.removeOverlays(view.overlays)
//        }
//
//        guard let route = route else { return }
//        let mapRect = route.boundingMapRect
//        view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
//        view.addOverlay(route)
//    }
//}

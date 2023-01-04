//
//  ZoomingMultiPolygonRenderer.swift
//  Stravo
//
//  Created by Bob Voorneveld on 04/01/2023.
//

import MapKit


public class ZoomingMultiPolygonRenderer : MKMultiPolygonRenderer {

    private var mapView: MKMapView!
    private var polylineWidth: Double! // Meters

    convenience public init(overlay: MKOverlay, mapView: MKMapView, polylineWidth: Double) {
        self.init(overlay: overlay)
        self.mapView = mapView
        self.polylineWidth = polylineWidth
    }

    override public func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        self.lineWidth = CGFloat(mapView.metersToPoints(meters: polylineWidth))
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}

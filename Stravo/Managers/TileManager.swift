//
//  TileManager.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import Foundation
import Combine
import MapKit
import Polyline

class TileManager {
    private let userStore: UserStore
    
    init(userStore: UserStore) {
        self.userStore = userStore
    }

    func loadTiles() async throws -> [MKOverlay]? {
        try await fetchTiles()
    }
    
    func checkForNewTiles(coordinates: [CLLocationCoordinate2D]) async throws -> [MKOverlay]? {
        try await fetchTiles(coordinates: coordinates)
    }
    
    private func fetchTiles(coordinates: [CLLocationCoordinate2D]? = nil) async throws -> [MKOverlay]? {
        var request = URLRequest(url: URL(string: "http://602e-2a02-a446-ae5d-1-dc3-3f17-3633-159f.ngrok.io/activities/tiles")!)
        guard let token = userStore.token else {
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let coordinates {
            request.httpMethod = "POST"
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(TilesPost(coordinates: coordinates))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode != 200 {
            throw StravoCloudError.invalidResponse
        }
        
        let decoder = MKGeoJSONDecoder()
        let geojson = try decoder.decode(data)
        
        return geojson as? [MKOverlay]
    }
    
    private struct TilesPost: Encodable {
        let polyline: String
        
        init(coordinates: [CLLocationCoordinate2D]) {
            polyline = Polyline(coordinates: coordinates).encodedPolyline
        }
    }
}

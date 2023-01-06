//
//  TileManager.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import Foundation
import Combine
import MapKit

class TileManager {
    private let userStore: UserStore
    
    init(userStore: UserStore) {
        self.userStore = userStore
    }

    func loadTiles() async throws -> [MKMultiPolygon]? {
        var request = URLRequest(url: URL(string: "http://dbd1-2a02-a446-ae5d-1-8505-d6f6-5c81-11bd.ngrok.io/activities/tiles")!)
        request.setValue("Bearer \(userStore.token!)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode != 200 {
            throw StravoCloudError.invalidResponse
        }
        
        let decoder = MKGeoJSONDecoder()
        let geojson = try decoder.decode(data)
        
        return geojson as? [MKMultiPolygon]
    }
}

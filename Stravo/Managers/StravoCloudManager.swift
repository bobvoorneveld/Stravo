//
//  StravoCloudManager.swift
//  Stravo
//
//  Created by Bob Voorneveld on 07/01/2023.
//

import Foundation


class StravoCloudManager {
    private let userStore: UserStore
    
    init(userStore: UserStore) {
        self.userStore = userStore
    }
    
    func syncRoutes() async throws {
        var request = URLRequest(url: URL(string: "http://602e-2a02-a446-ae5d-1-dc3-3f17-3633-159f.ngrok.io/activities/sync")!)
        guard let token = userStore.token else {
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode != 200 {
            throw StravoCloudError.invalidResponse
        }
    }
}

//
//  UserStore.swift
//  Stravo
//
//  Created by Bob Voorneveld on 04/01/2023.
//

import SwiftUI
import KeychainAccess


class UserStore: ObservableObject {
    @Published var token: String?
    @AppStorage("name") var name: String?
    @AppStorage("username") var username: String?
    
    private var keychain = Keychain(service: "nl.bobvoorneveld.Stravo")
    
    init() {
        if let username {
            token = keychain[username]
        }
    }

    func store(credentials: Credentials) {
        keychain[credentials.username] = credentials.token
        name = credentials.name
        username = credentials.username
        token = credentials.token
    }
}

struct Credentials: Decodable {
    let name: String
    let username: String
    let token: String
}

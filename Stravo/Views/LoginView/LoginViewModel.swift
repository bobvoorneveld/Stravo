//
//  LoginViewModel.swift
//  Stravo
//
//  Created by Bob Voorneveld on 04/01/2023.
//

import SwiftUI

extension LoginView {
    class ViewModel: ObservableObject {
        @Published var username = ""
        @Published var password = ""
        
        @Published var loading = false
        
        @Published var error: String?
        
        var loginEnabled: Bool {
            !(username.isEmpty || password.isEmpty)
        }
        
        private var userStore: UserStore
        
        init(userStore: UserStore) {
            self.userStore = userStore
        }
        
        @MainActor
        func login() async {
            loading = true
            var request = URLRequest(url: URL(string: "http://d1de-2a02-a446-ae5d-1-a580-e4e6-85a-e141.ngrok.io/users/token/login")!)
            request.httpMethod = "POST"
            let token = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode != 200 {
                    print(urlResponse.statusCode)
                    throw StravoCloudError.loginFailed
                }
                let credentials = try JSONDecoder().decode(Credentials.self, from: data)
                await MainActor.run {
                    loading = false
                    userStore.store(credentials: credentials)
                }
            } catch {
                await MainActor.run {
                    withAnimation {
                        self.loading = false
                        self.error = error.localizedDescription
                        self.password = ""
                    }
                }
            }
        }
    }
}

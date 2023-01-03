//
//  LoginView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var vm = ViewModel()

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack (spacing: 20) {
            Text("Login to Stravo")
                .font(.title)
                .padding(.bottom, 20)
            
            TextField("username", text: $vm.username)
                .textContentType(.emailAddress)
                .textCase(.lowercase)
                .textInputAutocapitalization(.never)
                .font(.system(size: 18))
                .foregroundColor(colorScheme == .light ? .indigo : .white)
                .padding()
                .background(.indigo.opacity(0.2))
                .cornerRadius(8)
            
            SecureField("password", text: $vm.password)
                .font(.system(size: 18))
                .foregroundColor(colorScheme == .light ? .indigo : .white)
                .padding()
                .background(.indigo.opacity(0.2))
                .cornerRadius(8)

            Button {
                Task {
                    await vm.login()
                }
            } label: {
                Text("Login")
                    .font(.system(size: 18))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .opacity(vm.loginEnabled ? 1.0: 0.5)
            }
            .disabled(!vm.loginEnabled)
            .background(.indigo.opacity(vm.loginEnabled ? 1.0: 0.5))
            .foregroundColor(.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .padding(.top, 50)
    }
}

private class ViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    
    var loginEnabled: Bool {
        !(username.isEmpty || password.isEmpty)
    }
    
    @MainActor
    func login() async {
        
        var request = URLRequest(url: URL(string: "http://localhost:8080/users/token/login")!)
        request.httpMethod = "POST"
        let token = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let token = try JSONDecoder().decode(LoginResponse.self, from: data)
            print(token.token)
        } catch {
            print(error)
        }
    }
}

struct LoginResponse: Decodable {
    let token: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  LoginView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject var vm: ViewModel

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if vm.loading {
                ZStack {
                    Color.indigo
                        .opacity(0.2)
                    
                    ProgressView("Login...")
                        .progressViewStyle(.circular)
                }
            }
            
            if let error = vm.error {
                
                ZStack {
                    Color.indigo
                    
                    VStack {
                        Text(error)
                            .foregroundColor(.white)
                        
                        Button {
                            vm.error = nil
                        } label: {
                            Text("Ok")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.white)
                        }
                        .foregroundColor(.indigo)
                        .cornerRadius(12)
                        .padding()
                    }
                }
            } else {
                
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
                    .disabled(!vm.loginEnabled || vm.loading)
                    .background(.indigo.opacity(vm.loginEnabled ? 1.0: 0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
                .padding(.top, 50)
            }
        }
        .ignoresSafeArea()
    }
}

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
            var request = URLRequest(url: URL(string: "http://localhost:8080/users/token/login")!)
            request.httpMethod = "POST"
            let token = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode != 200 {
                    print(urlResponse.statusCode)
                    throw LoginError.loginFailed
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

enum LoginError: Error, LocalizedError {
    case loginFailed
    
    var errorDescription: String? {
        "Login failed, please try again"
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

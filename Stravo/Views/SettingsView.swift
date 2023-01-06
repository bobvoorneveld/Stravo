//
//  SettingsView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 06/01/2023.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var vm: ViewModel
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {

        Button {
            vm.logoutButtonPressed()
        } label: {
            Text("Logout")
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .light ? Color.indigo : Color.white)
                .foregroundColor(colorScheme == .light ? Color.white : Color.indigo)
        }
        .cornerRadius(12)
        .padding()
        
        .confirmationDialog("Are you sure?", isPresented: $vm.showConfirmationDialog, titleVisibility: .visible) {
            Button("Ok") {
                vm.confirmLogout()
            }
        }
        .navigationTitle("Settings")

    }
    
    class ViewModel: ObservableObject {
        let userStore: UserStore
        
        @Published var showConfirmationDialog = false
        
        init(userStore: UserStore) {
            self.userStore = userStore
        }
        
        func logoutButtonPressed() {
            showConfirmationDialog = true
        }
        
        func confirmLogout() {
            userStore.logout()
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationStack {
                SettingsView(vm: .init(userStore: .init()))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

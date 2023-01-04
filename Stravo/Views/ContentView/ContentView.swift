//
//  ContentView.swift
//  Stravo
//
//  Created by Bob Voorneveld on 03/01/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userStore = UserStore()

    var body: some View {
        if userStore.token != nil {
            MainView(vm: .init(userStore: userStore))
        } else {
            LoginView(vm: .init(userStore: userStore))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  Expensify2021App.swift
//  Expensify2021
//
//  Created by Ryan on 11/15/21.
//

import SwiftUI
import Firebase

class AppState: ObservableObject {
    static let shared = AppState()
    enum Path {
        case landing, signIn, home
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .landing: EmptyView()
            case .signIn: SignInView() 
            case .home: ContentView()
            }
        }
    }
   
    @Published var root: Path = User.isLoggedIn ? .home : .signIn
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    static func showAlert(_ message: String) {
        shared.alertMessage = message
        shared.showAlert = true
    }
}

@main
struct Expensify2021App: App {
    @StateObject var appState = AppState.shared
    
    init() {
        FirebaseApp.configure()
        
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        return WindowGroup {
            NavigationView {
                appState.root.view
            }
            .overlay(Group {
                if appState.isLoading {
                    LoadingView()
                } else {
                    EmptyView()
                }
            })
            .alert(appState.alertMessage, isPresented: $appState.showAlert) {
                Button("OK", role: .cancel) { appState.showAlert = false }
            }
        }
    }
}

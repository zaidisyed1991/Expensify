//
//  ContentView.swift
//  ContentView
//
//  Created by Ryan on 11/24/21.
//
import SwiftUI
import Foundation
import Firebase

struct ContentView: View {
    enum Tab: Int {
        case home, submit, expenses
    }
    @State private var tabSelection: Tab = .home
    
    let appearance: UITabBarAppearance = UITabBarAppearance()
        init() {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
    
    
    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }.tag(Tab.home)
            SubmitView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Submit Expense")
                }.tag(Tab.submit)
            Group {
                if User.me.isManager {
                    UsersView()
                } else {
                    RecieptView(user: User.me)
                }
            }
            .tabItem {
                Image(systemName: "list.number")
                Text("Expenses")
            }.tag(Tab.expenses)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign Out") {
                    User.signOut()
                }
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var navTitle: String {
        switch tabSelection {
        case .home:
            return "Home"
        case .submit:
            return "Submit Expense"
        case .expenses:
            return "Expenses"
        }
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
           ContentView()
        }
    }
}

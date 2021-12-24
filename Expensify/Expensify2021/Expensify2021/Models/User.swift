//
//  User.swift
//  Expensify2021
//
//  Created by Syed on 27/11/2021.
//

import Firebase

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let isManager: Bool
    let fname: String
    let lname: String
    
    static var me: User! {
        get {
            if let data = UserDefaults.standard.data(forKey: "me") {
                return try? JSONDecoder().decode(User.self, from: data)
            }
            return nil
        }
        set {
            UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: "me")
        }
    }
    
    static var isLoggedIn: Bool {
        Auth.auth().currentUser != nil && User.me != nil
    }
    
    static func signOut() {
        try? Auth.auth().signOut()
        User.me = nil
        AppState.shared.root = .signIn
    }
}

extension User {
    init?(_ snapshot: DocumentSnapshot) {
        guard let data = snapshot.data()
        else { return nil }
        
        id = snapshot.documentID
        email = data["email"] as? String ?? ""
        isManager = data["isManager"] as? Bool ?? false
        fname = data["fname"] as? String ?? ""
        lname = data["fname"] as? String ?? ""
    }
}

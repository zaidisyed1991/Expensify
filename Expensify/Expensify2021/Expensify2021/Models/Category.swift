//
//  Category.swift
//  Expensify2021
//
//

import Firebase

struct Category: Codable, Identifiable {
    let id: String
    let name : String
    
    init?(_ snapshot: DocumentSnapshot) {
        guard let data = snapshot.data()
        else { return nil }
        
        id = snapshot.documentID
        name = data["name"] as? String ?? ""
    }
}

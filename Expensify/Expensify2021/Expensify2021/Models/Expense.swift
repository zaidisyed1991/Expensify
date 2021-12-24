//
//  Expense.swift
//  Expensify2021
//
//  Created by Syed on 27/11/2021.
//

import Firebase

struct Expense: Identifiable {
    let id: String
    let createdAt: Date
    let userId: String
    let company: String
    let category: String
    let receipt: String
    let expense: String
    var approval: String
    
    init?(_ snapshot: DocumentSnapshot) {
        guard let data = snapshot.data()
        else { return nil }
        
        id = snapshot.documentID
        createdAt = data["createdAt"] as? Date ?? Date()
        userId = data["userId"] as? String ?? ""
        company = data["company"] as? String ?? ""
        category = data["category"] as? String ?? ""
        receipt = data["receipt"] as? String ?? ""
        expense = data["expense"] as? String ?? ""
        approval = data["approval"] as? String ?? ""
    }
}

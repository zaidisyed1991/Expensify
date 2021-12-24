//
//  DB.swift
//  Expensify2021
//
//  Created by Syed on 27/11/2021.
//

import Firebase

let db: Firestore = {
    Firestore.firestore().settings = FirestoreSettings()
    return Firestore.firestore()
}()

let collectionUsers = db.collection("Users")
let collectionExpenses = db.collection("Expenses")
let collectionCategories = db.collection("Categories")

//
//  RecieptView.swift
//  RecieptView
//
//  Created by Ryan on 11/19/21.
//

import Foundation
import SwiftUI
import Firebase

//show all reciepts for user USERNAME
struct RecieptView: View {
    init(user: User) {
        self._viewModel = .init(wrappedValue: .init(user: user))
    }
    
    @StateObject var viewModel: RecieptViewModel
    
    var body: some View {
        Group {
        if viewModel.expenses.isEmpty {
            Text("No data")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(viewModel.expenses) { expense in
                    NavigationLink {
                        VStack {
                            Text(" ").padding()
                            Text("Company: \(expense.company)").multilineTextAlignment(.center).padding()
                            Text("Category: \(expense.category)").multilineTextAlignment(.center).padding()
                           
                            HStack {
                                Text("Receipt:")
                                if let url = URL(string: expense.receipt) {
                                    Button("\(expense.receipt)") {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                           
                            Text("Expense: \(expense.expense)").multilineTextAlignment(.center).padding()
                            Text("Date: \(expense.createdAt, formatter: itemFormatter)").multilineTextAlignment(.center).padding()
 
                            if User.me.isManager == true {//add approval buttons
                                VStack{
                                    HStack {
                                        Button(action: {
                                            collectionExpenses.document(expense.id).updateData([
                                                "approval" : "approved"
                                            ])
                                        }, label: {
                                            Label("Approve",systemImage: "checkmark")
                                                .foregroundColor(.white)
                                                .frame(width: 200, height: 40)
                                                .background(Color.green)
                                                .cornerRadius(15)
                                                .padding()
                                        })
                                        
                                        Button(action: {
                                            collectionExpenses.document(expense.id).updateData([
                                                "approval" : "rejected"
                                            ])
                                        }, label: {
                                             Label("Reject", systemImage: "xmark")
                                                .foregroundColor(.white)
                                                .frame(width: 200, height: 40)
                                                .background(Color.red)
                                                .cornerRadius(15)
                                                .padding()
                                        })
                                    }
                                }.frame(maxHeight: .infinity, alignment: .bottom)
                            }
                        }.background(
                            Image("background")
                               .resizable()
                               .edgesIgnoringSafeArea(.all)
                               .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                    } label: {
                        Text("Expense: \(expense.id), approval status: \(expense.approval)")
                    }// end label
                } // end for each - expense
                .onDelete(perform: deleteItems)
            }
            // end list
            
        }
        }.background(
            Image("background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
           
    } // end body
    
    private func deleteItems(offsets: IndexSet) {
        let batch = db.batch()
        for offset in offsets {
            batch.deleteDocument(collectionExpenses.document(viewModel.expenses[offset].id))
        }
        batch.commit { error in
            if let error = error {
                AppState.showAlert(error.localizedDescription)
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
}

class RecieptViewModel: ObservableObject {
    let user: User
    private var listener: ListenerRegistration?
    
    @Published var expenses = [Expense]()

    init(user: User) {
        self.user = user
        listener = collectionExpenses.whereField("userId", isEqualTo: user.id)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.expenses = snapshot?.documents.compactMap { Expense($0) } ?? []
            }
    }
    
    deinit {
        listener?.remove()
        listener = nil
    }
}

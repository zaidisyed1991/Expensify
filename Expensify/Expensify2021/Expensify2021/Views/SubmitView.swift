//
//  SubmitView.swift
//  SubmitView
//
//  Created by Ryan on 11/21/21.
//

import Firebase
import SwiftUI

struct SubmitView: View {
    @StateObject var appState = AppState.shared
    
    @State var company = ""
    @State var category = ""
    @State var receipt: URL?
    @State var expense = ""
    
    @State var showPicker = false
            
    @State private var categories = [Category]()
    
    var body: some View {
       
        List {
            Section {
                HStack {
                    Text("Company Name")
                    Text("*").foregroundColor(.red)
                }
                TextField("Your answer", text: $company)
            }
            .listRowSeparator(.hidden)
            
            
            Section {
                VStack {
                    HStack {
                        Text("Category")
                        Text("*").foregroundColor(.red)
                    }
                    Picker(selection: $category, label:
                        Text("Category")){
                        ForEach(categories) { category in
                            Text("\(category.name)")
                        }
                }.pickerStyle(.wheel)}
                    
                
            }//end section
            .listRowSeparator(.hidden)
            
            Section {
                HStack {
                    Text("Receipt")
                    Spacer()
                    Button(action: { showPicker.toggle() }) {
                        Image(systemName: "icloud.and.arrow.up")
                                .foregroundColor(.blue)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.blue, lineWidth: 1)
                        )
                    }
                    .sheet(isPresented: $showPicker) {
                        DocumentPicker(filePath: $receipt)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if let receipt = receipt {
                    Text((receipt.absoluteString as NSString).lastPathComponent)
                }
            }
            .listRowSeparator(.hidden)
            
            
            Section {
                HStack {
                    Text("Expense")
                    Text("*").foregroundColor(.red)
                }
                TextField("Your answer", text: $expense)
                    .keyboardType(.decimalPad)
            }
            .listRowSeparator(.hidden)
           
            
            Button("SUBMIT") {
                validate()
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            
            
        }.onAppear() {
            UITableView.appearance().backgroundColor = UIColor.clear
            UITableViewCell.appearance().backgroundColor = UIColor.clear
        }//end list
        .background(
            Image("background")
               .resizable()
               .edgesIgnoringSafeArea(.all)
               .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        .overlay(Group {
            if appState.isLoading {
                LoadingView()
            } else {
                EmptyView()
            }
        })//end overlay
        .onAppear {
            collectionCategories.getDocuments { snapshot, error in
                categories = snapshot?.documents.compactMap { Category($0) } ?? []
            }
        }//end appear
    }//end body

    
    
    func validate() {
        hideKeyboard()
        
        guard !company.isEmpty else {
            return AppState.showAlert("Please enter company name!")
        }
        
//        guard receipt != nil else {
//            return AppState.showAlert("Please upload your receipt!")
//        }
        
        guard !category.isEmpty else {
            return AppState.showAlert("Please select a category!")
        }
        
        guard !expense.isEmpty else {
            return AppState.showAlert("Please enter your expense!")
        }
        
        guard let _ = Double(expense) else {
            return AppState.showAlert("Please enter a valid expense!")
        }
                
        // add expense to User
        addItem()
    }
    
    private func addItem() {
        if let receipt = receipt, let data = try? Data(contentsOf: receipt) {
            appState.isLoading = true
            let ref = Firebase.Storage.storage().reference(withPath: "Receipts/\(User.me.id)/\(UUID().uuidString)_\(receipt.lastPathComponent)")
            ref.putData(data, metadata: nil) { meta, error in
                if let error = error {
                    appState.isLoading = false
                    AppState.showAlert(error.localizedDescription)
                } else {
                    ref.downloadURL(completion: { url, error in
                        if let url = url {
                            create(url.absoluteString)
                        } else {
                            AppState.showAlert(error?.localizedDescription ?? generalError)
                        }
                        appState.isLoading = false
                    })
                }
            }
        } else {
            create("")
        }
    }
    
    private func create(_ receiptURL: String) {
        collectionExpenses.addDocument(data: [
            "createdAt": Date(),
            "userId": User.me.id,
            "company": company,
            "category": categories.first(where: { $0.id == category })?.name ?? "",
            "receipt": receiptURL,
            "expense": expense,
            "approval" : "Not reviewed"
        ]) { error in
            if let error = error {
                AppState.showAlert(error.localizedDescription)
            } else {
                AppState.showAlert("The form has been submitted!")
                
                // reset
                company = ""
                category = ""
                receipt = nil
                expense = ""
            }
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

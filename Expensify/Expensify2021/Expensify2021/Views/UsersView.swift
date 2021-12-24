//
//  UsersView.swift
//  Expensify2021
//
//  Created by Syed on 27/11/2021.
//

import SwiftUI
import Firebase

struct UsersView: View { //admin/manager view
    @StateObject var viewModel = UsersViewModel()
    
    var body: some View {
        Group {
            if viewModel.users.isEmpty {
                Text("No data")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.users) { user in
                        NavigationLink() {
                            RecieptView(user: user)
                        } label: {
                            Text(user.email)
                        }
                    }
                }
                .background(Color.clear)
            }
        }
        .background(
            Image("background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}

class UsersViewModel: ObservableObject {
    private var listener: ListenerRegistration?
    @Published var users = [User]()
    
    init() {
        listener = collectionUsers
            .whereField("isManager", isEqualTo: false)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.users = snapshot?.documents.compactMap { User($0) } ?? []
            }
    }
    
    deinit {
        listener?.remove()
        listener = nil
    }
}

//
//  ContentView.swift
//  Final Project
//
//  Created by Ryan on 11/18/21.
//

import SwiftUI
import FirebaseAuth

struct CreateView: View {
    @StateObject var appState = AppState.shared
    @State var email: String = ""
    @State var password: String = ""
    @State var fname: String = ""
    @State var lname: String = ""
    @State var authenticationFailed: Bool = false
    @State var authenticationSucceeded: Bool = false
    @State var isSuccess = false
    @State var errorMessage = ""
    @State var successMessage = ""
    @State var expand = false
    @State var selection = "Employee"
    
    var ranks = ["Regular Employee", "Manager"]
    var body: some View {
        
        ZStack
        {
            VStack (spacing: 40)
            {
                CreateText()
                
                HStack {
                    FnameTextField(fname: $fname)
                    LnameTextField(lname: $lname)
                }
                
                UsernameTextField(email: $email)
                PasswordSecureField1(password: $password)
               
                
                if !isSuccess, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.caption))
                        .foregroundColor(.red)
                        .offset(y: -10)
                } //end if
                
                VStack(alignment: .leading, spacing: 18, content: {
                    Picker ("User Type", selection : $selection) {
                        ForEach(ranks, id: \.self) {
                            Text($0).foregroundColor(Color(red: 207 / 255, green: 255 / 255, blue: 249 / 255))
                        }
                    }.padding()
                        .foregroundColor(Color(red: 207 / 255, green: 255 / 255, blue: 249 / 255))
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color(red: 0 / 255, green: 25 / 255, blue: 115 / 255))
                        .cornerRadius(35.0)
                        
                })
                .padding(.bottom, 20)
               
             
                
                Button(action : {
                    guard validate() else {
                        return isSuccess = false
                    }
                    appState.isLoading = true
                    Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        if let user = result?.user {
                            collectionUsers.document(user.uid).setData(["email": email, "isManager": selection == "Manager", "fname": fname, "lname" : lname]) { error in
                            if let error = error {
                                AppState.showAlert(error.localizedDescription)
                                isSuccess = false
                            } else {
                                User.me = User(id: user.uid, email: email, isManager: false, fname : fname, lname: lname)
                                successMessage = "Successfully created account!"
                                isSuccess = true
                            }
                            appState.isLoading = false
                        }
                        } else {
                            errorMessage = error?.localizedDescription ?? generalError
                            isSuccess = false
                            appState.isLoading = false
                        }
                    }
                }) {
                    CreateBut()
                } //end createBut
                
                
            }
            .padding()
            
            if isSuccess && !successMessage.isEmpty {
                VStack {
                    Text(successMessage)
                        .font(.headline)
                        .padding()
                        .background(Color.yellow)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        appState.root = .home
                    }
                }
            } //end auth succ
        }//end zstack
        .background(
            Image("loginImg")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        )//end back
    }//end body
    
    func validate() -> Bool {
        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address!"
            return false
        }
        
        guard password.isValidPassword else {
            errorMessage = "The password must be 6 characters long or more!"
            return false
        }
        
        if fname == "" {
            errorMessage = "Please fill in your first name!"
            return false
        }
        
        if lname == "" {
            errorMessage = "Please fill in your last name!"
            return false
        }
        
        return true
    }
    
}//end struct

struct CreateText: View {
    var body: some View {
        Text("Create New User!").font(.title)
            .fontWeight(.bold)
            .padding(.bottom, 20)
            .foregroundColor(Color(red: 207 / 255, green: 255 / 255, blue: 249 / 255))
    }
}


struct CreateBut: View {
    var body: some View {
        Text("CREATE NEW USER")
            .fontWeight(.bold)
            .foregroundColor(Color(red: 207 / 255, green: 255 / 255, blue: 249 / 255))
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(red: 0 / 255, green: 25 / 255, blue: 115 / 255))
            .cornerRadius(35.0)
    }
}
struct FnameTextField: View {
    
    @Binding var fname: String
    
    var body: some View {
        TextField("First Name", text: $fname)
            .padding()
            .background(appColor)
            .cornerRadius(5.0)
            .padding(.bottom, 25)
    }
}

struct LnameTextField: View {
    
    @Binding var lname: String
    
    var body: some View {
        TextField("Last Name", text: $lname)
            .padding()
            .background(appColor)
            .cornerRadius(5.0)
            .padding(.bottom, 25)
    }
}

struct UsernameTextField: View {
    
    @Binding var email: String
    
    var body: some View {
        TextField("Email", text: $email)
            .padding()
            .background(appColor)
            .cornerRadius(5.0)
            .padding(.bottom, 25)
    }
}

struct PasswordSecureField1: View {
    @Binding var password: String
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(appColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct CreateView_Preview: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}

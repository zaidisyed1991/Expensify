import SwiftUI
import FirebaseAuth

let appColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0)

//if we want to use a demo with real email, rgorinso@umd.edu password: Password
//fake: admin@gmail.com, password: Admin123

struct SignInView: View {
    @StateObject var appState = AppState.shared
    @State var email: String = ""
    @State var password: String = ""
    @State var isSuccess = false
    @State var errorMessage = ""
    @State var successMessage = ""
    
    var body: some View {
        ZStack {
            VStack {
                HelloText()
                AppImage()
                EmailTextField(email: $email)
                PasswordSecureField(password: $password)
                
                if !isSuccess, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.caption))
                        .foregroundColor(.red)
                        .offset(y: -10)
                } //end if
                
                Button(action : {
                    guard validate() else {
                        return isSuccess = false
                    }
                    appState.isLoading = true
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let user = result?.user {
                            collectionUsers.document(user.uid).getDocument { snapshot, error in
                                User.me = User(id: user.uid, email: email, isManager: snapshot?.data()?["isManager"] as? Bool ?? false, fname: snapshot?.data()?["fname"] as? String ?? "", lname: snapshot?.data()?["lname"] as? String ?? "")
                                successMessage = "Successfully logged in!"
                                isSuccess = true
                                appState.isLoading = false
                            }
                        } else {
                            errorMessage = error?.localizedDescription ?? generalError
                            isSuccess = false
                            appState.isLoading = false
                        }
                    }
                }) {
                    LoginBut()
                } //end loginBut
                
                NavigationLink("Create New User", destination: CreateView())
            
                
            } //end vstack
            .padding()
            .background(
                Image("loginImg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            ) //end back

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
            
        } //end zstack
    } //end body
    
    func validate() -> Bool {
        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address!"
            return false
        }
        
        guard password.isValidPassword else {
            errorMessage = "The password must be 6 characters long or more!"
            return false
        }
        return true
    }
    
} //end view

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct HelloText: View {
    var body: some View {
        Text("Expensify!").font(.title)
            .fontWeight(.bold)
            .padding(.bottom, 20)
            .foregroundColor(Color(red: 207 / 255, green: 255 / 255, blue: 249 / 255))
    }
}

struct AppImage: View {
    var body: some View {
        Image("img")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
    }
}

struct LoginBut: View {
    var body: some View {
        Text("LOGIN")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color(red: 207 / 255, green: 255 / 255, blue: 249 / 255))
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(red: 0 / 255, green: 25 / 255, blue: 115 / 255))
            .cornerRadius(35.0)
    }
}

struct EmailTextField: View {
    
    @Binding var email: String
    
    var body: some View {
        TextField("Email", text: $email)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .padding()
            .background(appColor)
            .cornerRadius(5.0)
            .padding(.bottom, 25)
    }
}

struct PasswordSecureField: View {
    @Binding var password: String
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(appColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}


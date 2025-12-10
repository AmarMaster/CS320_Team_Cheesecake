//
//  LoginView.swift
//  EventTracker
//

import SwiftUI

struct LoginView: View {
    let fixedName: String
    let fixedEmail: String
    
    @State private var nameOrEmail = ""
    @State private var password = ""
    @State private var email = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var canContinue = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
                    Spacer().frame(height: 50)

                    Image("cheesecakeLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .padding(.bottom, 20)

                    Text("Login")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 12) {
                        TextField("Name or Email", text: $nameOrEmail, prompt: Text("Name or Email").foregroundColor(.gray))
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(UIColorFromRGB(0x312F2F)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        SecureField("Password", text: $password, prompt: Text("Password").foregroundColor(.gray))
                            .padding()
                            .background(Color(UIColorFromRGB(0x312F2F)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }.padding(.horizontal, 20)
                    
                    // Continue button
//                    NavigationLink(destination: ProfileView()) {
//                        Text("Login")
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color(UIColorFromRGB(0xFF5934)))
//                            .foregroundColor(.white)
//                            .cornerRadius(16)
//                    }.padding(.horizontal, 20)
//                        .padding(.vertical, 29)
                    Button(action: {
                        if nameOrEmail.isEmpty || password.isEmpty {
                            showError = true
                            errorMessage = "All fields are required."
                        } else if (nameOrEmail != fixedName && nameOrEmail != fixedEmail) || password.isEmpty {
                            showError = true
                            errorMessage = "Invalid username/email or password."
                        } else {
                            showError = false
                            canContinue = true
                        }
                    }) {
                        Text("Login")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColorFromRGB(0xFF5934)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        
                    }.padding(.horizontal, 20)
                        .padding(.top, 29)
                        .padding(.bottom, 10)
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    NavigationLink(destination: CreateAccountView()){
                        Text("Don't have an account? Create an account")
                    }
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                }
                .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $canContinue) {
                ProfileView(fixedName: fixedName, fixedEmail: fixedEmail)
            }
        }

    }
}

#Preview {
    LoginView(fixedName: "Your Name", fixedEmail: "email@umass.edu")
}

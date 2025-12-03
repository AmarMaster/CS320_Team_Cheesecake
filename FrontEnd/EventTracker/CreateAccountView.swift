//
//  createaccount.swift
//  EventTracker
//

import SwiftUI

struct CreateAccountView: View {
    @State private var name = ""
    @State private var password = ""
    @State private var email = ""
    
    @State private var showError = false
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

                    Text("Create an Account")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 12) {
                        TextField("Name", text: $name, prompt: Text("Name").foregroundColor(.gray))
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(UIColorFromRGB(0x312F2F)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        TextField("Email", text: $email, prompt: Text("Email").foregroundColor(.gray))
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
                    Button(action: {
                        if name.isEmpty || email.isEmpty || password.isEmpty {
                            showError = true
                        } else {
                            canContinue = true
                        }
                    }) {
                        Text("Create Account")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColorFromRGB(0xFF5934)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }.padding(.horizontal, 20)
                        .padding(.top, 29)
                        .padding(.bottom, 10)
                    
                    if showError {
                        Text("All fields are required.")
                            .foregroundColor(.red)
                            .font(.body)
                    }
                    
                    NavigationLink(destination: LoginView(fixedName: name, fixedEmail: email)){
                        Text("Have an account? Login")
                    }
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    

                }
            }
            .navigationDestination(isPresented: $canContinue) {
                LoginView(fixedName: name, fixedEmail: email)
            }
        }

    }
}

#Preview {
    CreateAccountView()
}


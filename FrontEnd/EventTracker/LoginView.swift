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
    @State private var canContinue = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
                    Spacer().frame(height: 50)

                    Text("Login")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 12) {
                        TextField("Name or Email", text: $nameOrEmail, prompt: Text("Name or Email").foregroundColor(.gray))
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
                        if (nameOrEmail.isEmpty || password.isEmpty) {
                            showError = true
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
                        .padding(.vertical, 29)
                    

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

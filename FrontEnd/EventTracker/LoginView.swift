//
//  LoginView.swift
//  EventTracker
//

import SwiftUI

struct LoginView: View {
    @State private var nameOrEmail = ""
    @State private var password = ""
    @State private var email = ""
    
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
                    NavigationLink(destination: ProfileView()) {
                        Text("Login")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColorFromRGB(0xFF5934)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }.padding(.horizontal, 20)
                        .padding(.vertical, 29)
                    
                    Text("Or Continue With")
                        .foregroundColor(.white)
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    // Social logins
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image(systemName: "applelogo")
                                .resizable()
                                .scaledToFit()
                            
                                .foregroundColor(.white)
                                .frame(width: 140, height: 30)
                                .padding()
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .cornerRadius(16)
                        }
                        
                        Button(action: {}) {
                            Image("instagramLogo 1")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 140, height: 30)
                                .padding()
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .cornerRadius(16)
                        }
                    }.padding(.horizontal, 20)
                    Spacer()
                    
                }
                .navigationBarHidden(true)
            }
        }

    }
}

#Preview {
    LoginView()
}

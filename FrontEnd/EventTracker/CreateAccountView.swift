//
//  createaccount.swift
//  EventTracker
//

import SwiftUI

struct CreateAccountView: View {
    @State private var name = ""
    @State private var password = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
                    Spacer().frame(height: 50)

                    Text("Create an Account")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 12) {
                        TextField("Name", text: $name)
                            .padding()
                            .background(Color(UIColorFromRGB(0x312F2F)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(UIColorFromRGB(0x312F2F)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(UIColorFromRGB(0x312F2F)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }.padding(.horizontal, 20)
                    
                    // Continue button
                    NavigationLink(destination: LoginView()) {
                        Text("Continue")
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
            }
        }

    }
}

#Preview {
    CreateAccountView()
}

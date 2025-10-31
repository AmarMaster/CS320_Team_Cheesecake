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
                    TextField("Name or Email", text: $nameOrEmail)
                        .padding()
                        .background(Color(UIColorFromRGB(0x312F2F)))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(UIColorFromRGB(0x312F2F)))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }.padding(.horizontal, 20)
                
                // Continue button
                Button(action: {
                    print("Login")
                }) {
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
                
                // nav bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                             .foregroundColor(.white)
                             .font(.system(size: 30))
                    }
 
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "map")
                                              .foregroundColor(.white)
                                              .font(.system(size: 30))
                    }
                  
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "person")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                    }
                
                }.padding(.horizontal, 70)
                
            }
            
            
        }
            

    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

#Preview {
    LoginView()
}

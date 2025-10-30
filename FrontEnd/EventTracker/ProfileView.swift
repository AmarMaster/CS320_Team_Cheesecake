//
//  ProfileView.swift
//  EventTracker
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
            
            // info
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        // settings button
                        Button(action: {}) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                            }
                        }
                    }
                    .onChange(of: selectedItem, initial: false) { oldItem, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                profileImage = uiImage
                            }
                        }
                    }
                    
                    // info
                    VStack {
                        Text("Your Name")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack (spacing: 10){
                            Image(systemName: "envelope")
                            Text(verbatim: "email@umass.edu")
                        }
                        .foregroundColor(.white)
                        .font(.subheadline)
                        HStack {
                            Image(systemName: "phone")
                            Text("999 999 9999")
                        }
                        .foregroundColor(.white)
                        .font(.subheadline)
                    }
                    
                    // your events
                    VStack {
                        Text("Your Events")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                    }.padding(.top, 20)
                
                }
                Spacer()
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
    ProfileView()
}

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
    
    @State private var events: [EventData] = []
    
    var body: some View {
        NavigationStack {
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
                                .padding(.leading, 20)
                        }
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 5) {
                            ForEach(events) { event in
                                HStack(alignment: .center, spacing: 16){
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                
                                       Text(event.title)
                                           .foregroundColor(.white)
                                           .bold()
                                           .font(.title3)
                                       
                                        
                                        HStack {
                                            Image(systemName: "mappin.and.ellipse")
                                            Text(event.location)
                                        }
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                       
                                        HStack {
                                            Image(systemName: "calendar")
                                            Text("\(event.date.formatted(.dateTime.month().day().year()))")
                                        }
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        
                                        HStack {
                                            Image(systemName: "clock")
                                            Text("\(event.time.formatted(.dateTime.hour().minute()))")
                                        }
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                   }
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(Color(UIColorFromRGB(0x312F2F)))
                                   .cornerRadius(16)
                                   .padding(.horizontal, 20)
                                }
           
                            
                                
                                
                            }
                        }
                        
                        Spacer()
                        // add event button
                        VStack {
                            NavigationLink(destination: AddEventView(events: $events)) {
                                Text("+ Add an Event")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColorFromRGB(0xFF5934)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }.padding(.horizontal, 20)
                                .padding(.vertical, 29)
                        }
                    
                    }
                    Spacer()
                    BottomNavBar()

                    }
                .navigationBarHidden(true)

            }
        }

    }
}

#Preview {
    ProfileView()
}

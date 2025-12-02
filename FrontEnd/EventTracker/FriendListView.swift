//
//  FriendListView.swift
//  EventTracker
//

import SwiftUI

struct Friend {
    let id = UUID()
    let name: String
    let profileImage: String?
}

struct FriendListView: View {
    let fixedName: String
    let fixedEmail: String
    
    @State private var searchText = ""
    @State private var friends: [Friend] = [
        Friend(name: "Friend1", profileImage: nil),
        Friend(name: "Friend2", profileImage: nil),
        Friend(name: "Friend3", profileImage: nil),
        Friend(name: "Friend4", profileImage: nil)
    ]
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
           
                    HStack {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                              .foregroundColor(.gray)
                            TextField("Search friends...", text: $searchText, prompt: Text("Search friends...").foregroundColor(.gray))
                              .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(UIColorFromRGB(0x312F2F)))
                        .cornerRadius(16)
                        
                    
                        Button("Search") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
              
                    
                    // Friends List
                    ScrollView {
                        // Header
                       Text("Friends")
                           .font(.title)
                           .fontWeight(.bold)
                           .foregroundColor(.white)
                           .padding(.leading, 20)
                           .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVStack(spacing: 10) {
                            ForEach(filteredFriends, id: \.id) { friend in
                                NavigationLink(destination: FriendProfileView(friendName: friend.name, fixedName: fixedName, fixedEmail: fixedEmail)) {
                                    HStack {
                                        // Profile Picture
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text(String(friend.name.prefix(1)))
                                                    .foregroundColor(.white)
                                                    .font(.title2)
                                                    .fontWeight(.semibold)
                                            )
                                        
                                        // Friend Name
                                        Text(friend.name)
                                            .foregroundColor(.white)
                                            .font(.title3)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        // Arrow
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    }
                                    .padding()
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .cornerRadius(16)
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    FriendListView(fixedName: "Your Name", fixedEmail: "email@umass.edu")
}

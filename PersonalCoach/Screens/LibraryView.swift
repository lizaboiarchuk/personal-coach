//
//  LibraryView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""

    var body: some View {
        
        TabView {
            NavigationView {
                ZStack {
                    Color("ColorGrey")
                        .ignoresSafeArea(.all, edges: .all)
                    VStack {
                        // Name at the top
                        Spacer()
                        Text("Workout library")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.ultraLight)
                            .foregroundColor(.black)
                        
                        // Search bar
                        TextField("Search", text: $searchText)
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .background(Color("ColorLightGrey"))
                            .cornerRadius(30)
                            .padding(.horizontal)
                            .padding(.bottom, 50)
                            .foregroundColor(Color("ColorDarkGreen"))

                        Spacer()
                        
                        // TableView
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(1...10, id: \.self) { index in
                                    NavigationLink(destination: WorkoutDetailsView(itemIndex: index, workoutTitle: "Light Morning Workout", workoutAuthor: "MadFit")) {
                                        LibraryCellView(title: "Light Morning Workout", author: "MadFit")
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                        } //: SCROLLVIEW
                        Spacer()
                        
                    } //: VSTACK
                    .navigationTitle("")
                    .navigationBarHidden(true)
                    
                } //: ZSTACK
                
            } //: NAVIGATIONVIEW
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
        
            Text("Second Tab")
                .tabItem {
                    Label("My workouts", systemImage: "bookmark.fill")
                }
        
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
            
        } //: TABVVIEW
        .accentColor(Color("ColorDarkGreen")) // Set the tab bar's active color
        .navigationBarBackButtonHidden(true)
    }
}


struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

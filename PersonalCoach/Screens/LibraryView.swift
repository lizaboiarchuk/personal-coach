//
//  LibraryView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI
import FirebaseStorage

struct LibraryView: View {
    
    
    @ObservedObject private var viewModel = LibraryViewModel()
    @State private var searchText = ""
    @State private var isFirstAppearance = true
    
    
    var body: some View {
        
        TabView {
            NavigationView {
                ZStack {
                    Color("ColorGrey")
                        .ignoresSafeArea(.all, edges: .all)
                    
                    if viewModel.downloadingPreviews {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                            .padding()
                    }
                    else {
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
                            
                            
                            ScrollView {
                                LazyVStack(spacing: 10) {
                                    
                                    ForEach(self.viewModel.workouts.indices, id: \.self) { index in
                                        let workout = self.viewModel.workouts[index]
                                        NavigationLink(destination: WorkoutDetailsView(workout: workout, delegate: self.viewModel)) {
                                            LibraryCellView(workout: workout, delegate: self.viewModel)
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                            } //: SCROLLVIEW
                            
                            Spacer()
                            
                        } //: VSTACK
                        .navigationTitle("")
                        .navigationBarHidden(true)
                    }
                    
                } //: ZSTACK
                
            } //: NAVIGATIONVIEW
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .onAppear {
                if self.isFirstAppearance {
                    viewModel.loadWorkoutPreviews()
                    self.isFirstAppearance = false
                }
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

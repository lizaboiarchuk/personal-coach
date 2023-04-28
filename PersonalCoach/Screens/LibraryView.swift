//
//  LibraryView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI
import FirebaseStorage

import SwiftUI
import FirebaseStorage

struct LibraryView: View {
    
    @ObservedObject private var viewModel = LibraryViewModel()
    @State private var searchText = ""
    @State private var isFirstAppearance = true
    @State private var selectedTab = 1
    
    private func contentView(forTab tab: Int) -> some View {
        VStack {
            // Name at the top
            Spacer()
            Text(tab == 1 ? "Workout library" : "Saved workouts")
                .font(.system(.title, design: .rounded))
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
            
            // Search bar
            if tab == 1 {
                TextField("Search", text: $searchText)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color("ColorLightGrey"))
                    .cornerRadius(30)
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                    .foregroundColor(Color("ColorDarkGreen"))
            }
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    let workoutModels = tab == 1 ? viewModel.workoutModels : viewModel.downloadedWorkoutModels
                    
                    ForEach(workoutModels.indices, id: \.self) { index in
                        let workoutModel = workoutModels[index]
                        
                        NavigationLink(destination: WorkoutDetailsView(model: workoutModel)) {
                            LibraryCellView(model: workoutModel)
                        }
                    }
                }
                .padding(.horizontal, 10)
            } //: SCROLLVIEW
            
            Spacer()
            
        } //: VSTACK
        .navigationBarHidden(true)
    }
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
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
                        contentView(forTab: 1)
                    }
                    
                } //: ZSTACK
                
            } //: NAVIGATIONVIEW
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(1) // Set the tag for the Home tab
            .onAppear {
                if self.isFirstAppearance {
                    viewModel.loadWorkoutPreviews()
                    self.isFirstAppearance = false
                }
            }
            
            NavigationView {
                ZStack {
                    Color("ColorGrey")
                        .ignoresSafeArea(.all, edges: .all)
                    
                    contentView(forTab: 2)
                } //: ZSTACK
            }
            .tabItem {
                Label("Saved workouts", systemImage: "bookmark.fill")
            }
            .tag(2) // Set the tag for the Saved Workouts tab
            
            NavigationView {
                Text("Profile")
            }
            .tabItem {
                Label("About", systemImage: "person.crop.circle.fill")
            }
            .tag(3) // Set
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

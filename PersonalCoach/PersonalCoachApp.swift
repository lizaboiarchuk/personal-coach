//
//  PersonalCoachApp.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

@main
struct PersonalCoachApp: App {
    
    init() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.unselectedItemTintColor = UIColor.gray // Non-active tab icon color
        UITextField.appearance().textColor = .black
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

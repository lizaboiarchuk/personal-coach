//
//  LazyView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.04.2023.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

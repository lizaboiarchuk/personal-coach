//
//  CircleGroupView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

struct CircleGroupView: View {
    // MARK: - Property
    
    @State var ShapeColor: Color
    @State var ShapeOpacity: Double
    @State var ShapeOpacityInner: Double
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(ShapeColor.opacity(ShapeOpacityInner), lineWidth: 40)
                .frame(width: 260, height: 260, alignment: .center)
            Circle()
                .stroke(ShapeColor.opacity(ShapeOpacity), lineWidth: 60)
                .frame(width: 260, height: 260, alignment: .center)
        } //: ZSTACK
        .blur(radius: isAnimating ? 0 : 10)
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1 : 0.5)
        .animation(.easeOut(duration: 1), value: isAnimating)
        .onAppear(perform: {
            isAnimating = true 
        })
    }
}

struct CircleGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("ColorGrey")
                .ignoresSafeArea(.all, edges: .all)
            CircleGroupView(ShapeColor: Color("ColorLightGrey"), ShapeOpacity: 0.5, ShapeOpacityInner: 0.9)
        }
    }
}

//
//  AboutView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.04.2023.
//

import SwiftUI





struct AboutView: View {
    
    @State private var isAnimating = false
    var title = "How it works?🏃🏻‍♀️"
    var text = """
        Our personal coach app is designed to help you improve your fitness and exercise routines with the help of cutting-edge technology. Using pose detection and statistical AI algorithms, our app tracks your movements during workouts and compares them to a pre-recorded video of your coach.

        Here's how it works: first, you select a workout routine from our library of exercises. Then, you start the workout and position your phone or tablet so that it can detect your movements using its camera. Our app's AI algorithms analyze your movements and compare them to the pre-recorded video of your coach performing the same routine.

        The app will provide you with real-time feedback on your technique, and show you where you can improve your form. It will also give you encouragement and motivation to keep going, so you can get the most out of your workout.

        One of the best things about our app is that everything is processed on your device - nothing is sent from your phone. Your privacy is important to us, and we want to ensure that your data is secure and protected.
    """
    
    
    
    var body: some View {
        
        ZStack {
            // Add the image as the bottom-most layer
            Color("ColorGrey")
                .ignoresSafeArea(.all, edges: .all)
            Image("start-background")
                .resizable()
                .opacity(0.1)
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .offset(y: isAnimating ? -45 : 45)
                .animation(
                    Animation
                        .easeInOut(duration: 4)
                        .repeatForever()
                    
                    ,value: isAnimating
                )
            
            ScrollView {
                VStack {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.ultraLight)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 80)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 30)
                    
                    Text(text)
                        .font(.title3)
                        .fontWeight(.ultraLight)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 30)
                }
            }
        }
        .onAppear(perform: {
            DispatchQueue.main.async {
                isAnimating = true
            }
        })
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

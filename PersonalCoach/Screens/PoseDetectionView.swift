//
//  ContentView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 09.04.2023.
//

import SwiftUI
import AVFoundation
import Accelerate.vImage
import UIKit
import os

struct OverlayViewWrapper: UIViewRepresentable {
    let imageView: UIImageView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.addSubview(imageView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        imageView.frame = uiView.bounds
    }
}


struct PoseDetectionView: View {
    
    @ObservedObject var detectionViewModel: PoseDetectionViewModel
    @ObservedObject var streamerViewModel: VideoStreamerViewModel
    
    @State private var showOverlay = true
    @State private var counter = 5
    @State private var showAlert = false
    @State private var shouldDismiss = false
    @State private var currentLabel = ""
    @State private var isLabelVisible = false

    private var onDismiss: (() -> Void)?
    private var workout: WorkoutPreview
    
    
    func randomizeLabelVisibility() {
        let randomShowInterval = Double.random(in: 0.3...3.0) // Adjust the range as needed
        let randomHideInterval = Double.random(in: 0.5...2.5) // Adjust the range as needed

        DispatchQueue.main.asyncAfter(deadline: .now() + randomShowInterval) {
            withAnimation {
                currentLabel = MotivationalPhrases.phrases.randomElement() ?? "Keep going!"
                isLabelVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + randomHideInterval) {
                withAnimation {
                    isLabelVisible = false
                }
                randomizeLabelVisibility()
            }
        }
    }

    
    init(workout: WorkoutPreview, onDismiss: (() -> Void)?) {
        print("init pose detection")
        self.detectionViewModel = PoseDetectionViewModel(workout: workout)
        self.streamerViewModel = VideoStreamerViewModel(videoPath: workout.localVideoPath)
        self.onDismiss = onDismiss
        self.workout = workout
        randomizeLabelVisibility()
    }
    
    var body: some View {
        
        ZStack {
            NavigationView {
                
                ZStack {
                    
                    OverlayViewWrapper(imageView: detectionViewModel.overlayView)
                        .aspectRatio(3.0/4.0, contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .scaleEffect(x: -1, y: 1)
                    
                    ZStack {
                        VideoPlayerView(viewModel: streamerViewModel)
                            .frame(width: 300, height: 170)
                            .position(x: UIScreen.main.bounds.width * 0.60, y: UIScreen.main.bounds.height * 0.10)
                            .onAppear {
                                streamerViewModel.startVideo()
                            }
                        
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text("Text")
                                    .foregroundColor(.black)
                            )
                            .offset(x: 25, y: UIScreen.main.bounds.height/2 - 25)
                        
                        VStack {
                            if isLabelVisible {
                                Text(currentLabel)
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .position(x: UIScreen.main.bounds.width * 0.60, y: UIScreen.main.bounds.height * 0.35)
                        .onAppear {
                            randomizeLabelVisibility()
                        }
                    }
                    
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                showAlert = true
                                detectionViewModel.isPaused = true
                                streamerViewModel.stopStreaming()
                            }, label: {
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color("ColorLightGrey").opacity(0.5))
                                        .frame(width: 75, height: 75)
                                    
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.black)
                                }
                            })
                        }
                        .padding(.bottom, 50)
                        .padding(.top, -175) // Add this line to move the buttons up
                        .alignmentGuide(.bottom) { _ in UIScreen.main.bounds.height * 0.5 }
                    } //: PAUSE CANCEL BUTTONS
                }//:ZSTACK
            } //:NAVIGATIONVIEW
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            
            if detectionViewModel.showOverlay {
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Text("\(detectionViewModel.counter)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Quit Workout"), message: Text("Are you sure you want to quit?"), primaryButton: .cancel(Text("No")) {
                showAlert = false
                detectionViewModel.isPaused = false
                streamerViewModel.resumeStreaming()
                
            }, secondaryButton: .destructive(Text("Yes")) {
                detectionViewModel.quit()
                streamerViewModel.quit()
                shouldDismiss = true
                onDismiss?()
                
            })
        })
        .onAppear {
            detectionViewModel.startCountdown()
        }
//        .onDisappear {
//            print("disapperingggg")
//            detectionViewModel.quit()
//            streamerViewModel.quit()
//
//        }
        
    }
}

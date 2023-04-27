//
//  VideoStreamer.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 24.04.2023.
//

import SwiftUI
import AVFoundation
import Accelerate.vImage
import UIKit
import os

// MARK: - View
import SwiftUI
import AVFoundation

// MARK: - View
struct VideoPlayerView: View {
    @ObservedObject var viewModel: VideoStreamerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VideoPlayerUIView(viewModel: viewModel, frame: geometry.frame(in: .local))
        }
    }
}

struct VideoPlayerUIView: UIViewRepresentable {
    @ObservedObject var viewModel: VideoStreamerViewModel
    var frame: CGRect
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(viewModel.playerLayer)
        viewModel.playerLayer.frame = frame
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        viewModel.playerLayer.frame = frame
    }
}

// MARK: - Preview
struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(viewModel: VideoStreamerViewModel(videoPath: "path/to/video"))
    }
}

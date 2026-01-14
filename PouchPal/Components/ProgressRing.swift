//
//  ProgressRing.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let showPercentage: Bool
    let gradientColors: [Color]
    
    init(
        progress: Double,
        lineWidth: CGFloat = 12,
        size: CGFloat = 200,
        showPercentage: Bool = false,
        gradientColors: [Color] = [.ppSecondaryFallback, .ppPrimaryFallback]
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.showPercentage = showPercentage
        self.gradientColors = gradientColors
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.opacity(0.15),
                    lineWidth: lineWidth
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(PPAnimation.smooth, value: progress)
            
            // Optional percentage text
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(PPFont.headline())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Mini Progress Ring
struct MiniProgressRing: View {
    let progress: Double
    let isOverLimit: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    isOverLimit ? Color.ppDangerFallback : Color.ppPrimaryFallback,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(PPAnimation.smooth, value: progress)
        }
        .frame(width: 24, height: 24)
    }
}

#Preview {
    VStack(spacing: 40) {
        ProgressRing(progress: 0.65)
        ProgressRing(progress: 0.85, lineWidth: 8, size: 100, showPercentage: true)
        MiniProgressRing(progress: 0.7, isOverLimit: false)
        MiniProgressRing(progress: 1.0, isOverLimit: true)
    }
    .padding()
}

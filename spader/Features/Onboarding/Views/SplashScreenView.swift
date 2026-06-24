//
//  SplashScreenView.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct SplashScreenView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.colorScheme) var colorScheme
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            if isActive {
                if hasCompletedOnboarding {
                    MainView()
                        .transition(.opacity)
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            } else {
                splashContent
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var splashContent: some View {
        ZStack {
            GradientBackground()
            
            HStack(spacing: 10) {
                Image(.spader)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Image(.upnvy)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Text("Spader")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            textOffset = 0
            textOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }
}
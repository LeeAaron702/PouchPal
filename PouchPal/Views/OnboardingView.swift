//
//  OnboardingView.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI

struct OnboardingView: View {
    @Bindable var settings: UserSettings
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(UIColor.systemBackground),
                    Color.ppPrimaryFallback.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    UnitLabelPage(settings: settings)
                        .tag(1)
                    
                    LimitPage(settings: settings)
                        .tag(2)
                    
                    PrivacyPage()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(PPAnimation.smooth, value: currentPage)
                
                // Navigation
                navigationSection
            }
        }
    }
    
    // MARK: - Navigation Section
    private var navigationSection: some View {
        VStack(spacing: PPSpacing.lg) {
            // Page indicators
            HStack(spacing: PPSpacing.sm) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index == currentPage ? Color.ppPrimaryFallback : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(PPAnimation.smooth, value: currentPage)
                }
            }
            
            // Buttons
            HStack(spacing: PPSpacing.md) {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .font(PPFont.body(.medium))
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if currentPage < 3 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage < 3 ? "Continue" : "Get Started")
                        .font(PPFont.body(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, PPSpacing.xl)
                        .padding(.vertical, PPSpacing.md)
                        .background(
                            Capsule()
                                .fill(Color.ppPrimaryFallback)
                        )
                }
            }
            .padding(.horizontal, PPSpacing.xl)
            .padding(.bottom, PPSpacing.xl)
        }
    }
    
    private func completeOnboarding() {
        PPHaptics.notification(.success)
        settings.hasCompletedOnboarding = true
        onComplete()
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: PPSpacing.xl) {
            Spacer()
            
            // App icon placeholder
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.ppPrimaryFallback, Color.ppSecondaryFallback],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.ppPrimaryFallback.opacity(0.3), radius: 20, y: 10)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: PPSpacing.md) {
                Text("Welcome to PouchPal")
                    .font(PPFont.title(.bold))
                    .multilineTextAlignment(.center)
                
                Text("Track your daily usage with a simple tap.\nUnderstand your patterns over time.")
                    .font(PPFont.body())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, PPSpacing.xl)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Unit Label Page
struct UnitLabelPage: View {
    @Bindable var settings: UserSettings
    
    var body: some View {
        VStack(spacing: PPSpacing.xl) {
            Spacer()
            
            Image(systemName: "textformat")
                .font(.system(size: 50))
                .foregroundStyle(Color.ppPrimaryFallback)
            
            VStack(spacing: PPSpacing.md) {
                Text("Customize Labels")
                    .font(PPFont.title(.bold))
                
                Text("How would you like to refer to your entries?")
                    .font(PPFont.body())
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: PPSpacing.md) {
                HStack {
                    Text("Singular")
                        .font(PPFont.body())
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    TextField("pouch", text: $settings.unitLabelSingular)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                        .multilineTextAlignment(.center)
                }
                
                HStack {
                    Text("Plural")
                        .font(PPFont.body())
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    TextField("pouches", text: $settings.unitLabelPlural)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(PPSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PPRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .padding(.horizontal, PPSpacing.xl)
            
            // Preview
            VStack(spacing: PPSpacing.xs) {
                Text("Preview")
                    .font(PPFont.small())
                    .foregroundStyle(.tertiary)
                
                Text("5 \(settings.unitLabelPlural) today")
                    .font(PPFont.headline())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Limit Page
struct LimitPage: View {
    @Bindable var settings: UserSettings
    
    var body: some View {
        VStack(spacing: PPSpacing.xl) {
            Spacer()
            
            Image(systemName: "gauge.with.needle")
                .font(.system(size: 50))
                .foregroundStyle(Color.ppSecondaryFallback)
            
            VStack(spacing: PPSpacing.md) {
                Text("Set a Daily Limit")
                    .font(PPFont.title(.bold))
                
                Text("Optional: Set a target to track progress.\nYou can change this anytime in Settings.")
                    .font(PPFont.body())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: PPSpacing.lg) {
                Toggle("Enable Daily Limit", isOn: $settings.dailyLimitEnabled)
                    .font(PPFont.body(.medium))
                
                if settings.dailyLimitEnabled {
                    VStack(spacing: PPSpacing.md) {
                        Text("\(settings.dailyLimitValue)")
                            .font(PPFont.largeTitle())
                            .foregroundStyle(Color.ppSecondaryFallback)
                        
                        Text("\(settings.unitLabelPlural) per day")
                            .font(PPFont.body())
                            .foregroundStyle(.secondary)
                        
                        Stepper("", value: $settings.dailyLimitValue, in: 1...50)
                            .labelsHidden()
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(PPSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PPRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .padding(.horizontal, PPSpacing.xl)
            .animation(PPAnimation.smooth, value: settings.dailyLimitEnabled)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Privacy Page
struct PrivacyPage: View {
    var body: some View {
        VStack(spacing: PPSpacing.xl) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.ppSuccessFallback)
            
            VStack(spacing: PPSpacing.md) {
                Text("Your Privacy Matters")
                    .font(PPFont.title(.bold))
                
                Text("Everything stays on your device.")
                    .font(PPFont.body())
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: PPSpacing.lg) {
                PrivacyFeatureRow(
                    icon: "iphone",
                    title: "Local Storage Only",
                    description: "All data is stored securely on your device"
                )
                
                PrivacyFeatureRow(
                    icon: "person.slash",
                    title: "No Accounts",
                    description: "No sign-up, no login, no tracking"
                )
                
                PrivacyFeatureRow(
                    icon: "wifi.slash",
                    title: "Works Offline",
                    description: "No internet connection required"
                )
                
                PrivacyFeatureRow(
                    icon: "hand.raised.fill",
                    title: "No Data Sharing",
                    description: "Your data is never shared or sold"
                )
            }
            .padding(PPSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PPRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .padding(.horizontal, PPSpacing.xl)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Privacy Feature Row
struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: PPSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.ppSuccessFallback)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PPFont.body(.semibold))
                
                Text(description)
                    .font(PPFont.small())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView(settings: UserSettings()) {}
}

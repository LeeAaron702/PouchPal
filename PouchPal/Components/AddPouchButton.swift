//
//  AddPouchButton.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI

struct AddPouchButton: View {
    let action: () -> Void
    let quickAddAction: (Int) -> Void
    
    var body: some View {
        Button {
            PPHaptics.impact(.medium)
            action()
        } label: {
            mainButton
        }
        .buttonStyle(ScaleButtonStyle())
        .contextMenu {
            Button(action: { quickAddAction(1) }) {
                Label("Add 1", systemImage: "plus")
            }
            Button(action: { quickAddAction(2) }) {
                Label("Add 2", systemImage: "plus.circle")
            }
            Button(action: { quickAddAction(3) }) {
                Label("Add 3", systemImage: "plus.circle.fill")
            }
        }
        .accessibilityLabel("Add pouch")
        .accessibilityHint("Tap to log one pouch. Long press for quick add options.")
    }
    
    private var mainButton: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.ppPrimaryFallback.opacity(0.3),
                            Color.ppPrimaryFallback.opacity(0)
                        ],
                        center: .center,
                        startRadius: 35,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            
            // Main button
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.ppPrimaryFallback,
                            Color.ppPrimaryFallback.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: Color.ppPrimaryFallback.opacity(0.4), radius: 12, y: 6)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            // Plus icon
            Image(systemName: "plus")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(PPAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct PPSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            PPHaptics.impact(.light)
            action()
        }) {
            HStack(spacing: PPSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(PPFont.caption(.semibold))
            }
            .foregroundStyle(Color.ppPrimaryFallback)
            .padding(.horizontal, PPSpacing.md)
            .padding(.vertical, PPSpacing.sm)
            .background(
                Capsule()
                    .fill(Color.ppPrimaryFallback.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(Color.ppPrimaryFallback.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(PPAnimation.quick, value: isPressed)
    }
}

#Preview {
    VStack(spacing: 40) {
        AddPouchButton(action: {}, quickAddAction: { _ in })
        
        PPSecondaryButton("Undo", icon: "arrow.uturn.backward") {}
    }
    .padding()
}

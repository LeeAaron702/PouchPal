//
//  StatCard.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let color: Color
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        color: Color = .ppPrimaryFallback
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            HStack {
                Text(title)
                    .font(PPFont.caption(.medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(color.opacity(0.7))
                }
            }
            
            Text(value)
                .font(PPFont.title(.bold))
                .foregroundStyle(color)
            
            if let subtitle {
                Text(subtitle)
                    .font(PPFont.small())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(PPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: PPRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Large Stat Display
struct LargeStat: View {
    let value: Int
    let label: String
    let sublabel: String?
    
    var body: some View {
        VStack(spacing: PPSpacing.xs) {
            Text("\(value)")
                .font(PPFont.largeTitle())
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            Text(label)
                .font(PPFont.headline())
                .foregroundStyle(.secondary)
            
            if let sublabel {
                Text(sublabel)
                    .font(PPFont.caption())
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Inline Stat
struct InlineStat: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(PPFont.body())
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(PPFont.body(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, PPSpacing.sm)
    }
}

#Preview {
    VStack(spacing: 20) {
        LargeStat(value: 7, label: "pouches", sublabel: "today")
        
        HStack(spacing: 12) {
            StatCard(title: "7-Day Avg", value: "6.2", icon: "chart.bar.fill")
            StatCard(title: "30-Day Avg", value: "7.1", icon: "calendar", color: .ppSecondaryFallback)
        }
        
        VStack {
            InlineStat(title: "Yesterday", value: "8")
            Divider()
            InlineStat(title: "This Week", value: "43")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    .padding()
}

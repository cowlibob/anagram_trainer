//
//  TrainingModeButton.swift
//  AnagramTrainer
//
//  Created by James Cowlishaw on 11/12/2025.
//

import SwiftUI

struct MenuButton: View {
    let title: String
    let icon: String?
    let color: Color
    var badge: String? = nil
    var showCurrent: Bool = false
    var isCompact: Bool = false

    @Environment(\.scalingFactor) var scalingFactor
    
    private var fontSize: CGFloat {
        20.0 * scalingFactor
    }

    private var iconFrameWidth: CGFloat {
        20.0 * scalingFactor
    }

    private var horizontalPadding: CGFloat {
        (isCompact ? 10.0 : 20.0) * scalingFactor
    }

    private var contentSpacing: CGFloat {
        (isCompact ? 16.0 : 20.0) * scalingFactor
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            // Main content
            HStack(spacing: contentSpacing) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.custom("Din", size: fontSize))
                        .padding(.leading, horizontalPadding)
                        .frame(width: iconFrameWidth)
                    Text(title)
                        .font(.custom("Din", size: fontSize))
                        .padding(.leading, isCompact ? 0 : horizontalPadding)
                } else {
                    Text(title)
                        .font(.custom("Din", size: fontSize))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, alignment: icon == nil ? .center : .leading)

            // Right-aligned content
            HStack(spacing: 10) {
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primary.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primary.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.trailing, horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .foregroundStyle(.primary)
        .padding()
        .padding(.vertical, 8 * scalingFactor)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.001)) // Essential for hit testing
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Heavier border for current selection
            if showCurrent {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.white, lineWidth: 3 * scalingFactor)
            }
            
            content
            
            // Corner dot for current selection
            if showCurrent {
                Circle()
                    .fill(.white)
                    .frame(width: 10 * scalingFactor, height: 10 * scalingFactor)
                    .padding(8 * scalingFactor)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 0)
            }
        }
        .contentShape(Rectangle()) // Essential for hit testing
    }
}

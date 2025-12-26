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

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    private var fontSize: CGFloat {
        isLargeDevice ? 32.0 : 20.0
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            // Left-aligned content
            HStack(spacing: 20) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.custom("Din", size: fontSize))
                        .padding(.leading, isLargeDevice ? 32.0 : 20.0)
                        .frame(width: 20.0)
                    Text(title)
                        .font(.custom("Din", size: fontSize))
                        .padding(.leading, isLargeDevice ? 64.0 : 20.0)
                } else {
                    Text(title)
                        .font(.custom("Din", size: fontSize))
                        .padding(.leading, isLargeDevice ? 32.0 : 20.0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right-aligned content
            HStack(spacing: 10) {
                if showCurrent {
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primary.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primary.opacity(0.15))
                        .cornerRadius(8)
                }

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
            .padding(.trailing, isLargeDevice ? 32.0 : 20.0)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .foregroundStyle(.primary)
        .padding()
        .padding(.vertical, isLargeDevice ? 16 : 0)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.001)) // Essential for hit testing
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            content
        }
        .contentShape(Rectangle()) // Essential for hit testing
    }
}

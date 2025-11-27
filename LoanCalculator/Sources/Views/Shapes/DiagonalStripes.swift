//
//  DiagonalStripes.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import SwiftUI

// MARK: - Diagonal Stripes Shape
struct DiagonalStripes: Shape {
    let width: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let lineWidth = width
        let lineSpacing = width / 2
        
        // Вычисляем диагональную длину
        let diagonal = sqrt(rect.width * rect.width + rect.height * rect.height)
        let fullStripeWidth = lineWidth + lineSpacing
        
        // Рисуем полоски по диагонали (справа налево вниз)
        var offset: CGFloat = -diagonal
        while offset < diagonal {
            // Меняем X координаты местами
            path.move(to: CGPoint(x: rect.width - offset, y: -rect.height))
            path.addLine(to: CGPoint(x: rect.width - (offset + diagonal * 2), y: diagonal * 2))
            offset += fullStripeWidth
        }
        
        return path
    }
}

// Пример использования

// Диагональные полоски
//DiagonalStripes(width: lineHeight / 3)
//    .stroke(
//        Color.primary.opacity(0.2),
//        lineWidth: lineHeight / 6
//    )
//    .frame(height: lineHeight)
//    .cornerRadius(lineHeight / 2)
//    .clipped()

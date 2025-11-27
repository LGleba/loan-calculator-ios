//
//  CustomSlider.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import SwiftUI

// MARK: - Custom Slider
struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let color: Color
    let onChanged: (Double, Double) -> Void
    
    @State private var isDragging = false
    
    // Параметры внешнего вида
    private let lineHeight: CGFloat = 24
    private let circleSize: CGFloat = 48
    
    // Цвета и градиенты
    private let activeLineGradient: LinearGradient
    private let circleGradient: RadialGradient
    
    init(value: Binding<Double>, range: ClosedRange<Double>, step: Double, color: Color, onChanged: @escaping (Double, Double) -> Void) {
        self._value = value
        self.range = range
        self.step = step
        self.color = color
        self.onChanged = onChanged
        
        activeLineGradient = LinearGradient(
            colors: [
                color,
                color.mix(with: .white, by: 0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        circleGradient = RadialGradient(
            colors: [
                color.mix(with: .white, by: 0.3),
                color.mix(with: .black, by: 0.5)
            ],
            center: .center,
            startRadius: 5,
            endRadius: 35
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let usableWidth = trackWidth - circleSize
            
            ZStack(alignment: .leading) {
                
                // Диагональные полоски
                DiagonalStripes(width: lineHeight / 3)
                    .stroke(
                        Color.primary.opacity(0.2),
                        lineWidth: lineHeight / 6
                    )
                    .frame(height: lineHeight)
                    .cornerRadius(lineHeight / 2)
                    .clipped()
                
                // Заполненная часть с градиентом
                Rectangle()
                    .fill(activeLineGradient)
                    .frame(
                        width: calculateProgress(totalWidth: trackWidth),
                        height: lineHeight
                    )
                    .cornerRadius(lineHeight / 2)
                
                // кружочек с градиентом
                Circle()
                    .fill(circleGradient)
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        Circle()
                            .stroke(
                                color.mix(with: .white, by: 0.3),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: color.mix(with: .white, by: 0.3), radius: isDragging ? 8 : 4, x: 0, y: 0)
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .offset(x: calculateThumbOffset(usableWidth: usableWidth))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                if !isDragging {
                                    isDragging = true
                                }
                                updateValue(with: gesture, usableWidth: usableWidth)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
            .frame(height: circleSize)
        }
        .frame(height: circleSize)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
    }
    
    // Вычисление прогресса для заполненной части
    private func calculateProgress(totalWidth: CGFloat) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(normalizedValue) * totalWidth
    }
    
    // Вычисление смещения circle
    private func calculateThumbOffset(usableWidth: CGFloat) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(normalizedValue) * usableWidth
    }
    
    // Обновление значения при перетаскивании
    private func updateValue(with gesture: DragGesture.Value, usableWidth: CGFloat) {
        let dragPosition = max(0, min(gesture.location.x - circleSize / 2, usableWidth))
        let normalizedValue = dragPosition / usableWidth
        var newValue = range.lowerBound + (normalizedValue * (range.upperBound - range.lowerBound))
        
        // Применяем шаг (step)
        if step > 0 {
            newValue = round(newValue / step) * step
        }
        
        // Ограничиваем значение в пределах range
        newValue = max(range.lowerBound, min(newValue, range.upperBound))
        
        if newValue != value {
            let oldValue = value
            value = newValue
            onChanged(oldValue, newValue)
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var sliderValue: Double = 14
        
        var body: some View {
            VStack(spacing: 24) {
                HStack {
                    Text("How long ?")
                        .font(.title)
                    
                    Spacer(minLength: 0)
                    
                    Text("\(Int(sliderValue)) days")
                        .font(.title)
                        .fontWeight(.medium)
                }
                .padding(.horizontal)
                
                CustomSlider(
                    value: $sliderValue,
                    range: 7...28,
                    step: 1,
                    color: .orange,
                    onChanged: { old, new in
                        print("Изменилось: \(old) → \(new)")
                    }
                )
                .padding(.horizontal)
                
                HStack {
                    Text("7")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("28")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}

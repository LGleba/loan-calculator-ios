//
//  View+SaveSize.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import SwiftUI

// MARK: Сохранение размера View когда нам нужно понять какой размер самого View
struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: SizePreferenceKey.self,
                            value: proxy.size
                        )
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                // Обновляется при ЛЮБОМ изменении размера
                if size != newSize {
                    size = newSize
                }
            }
    }
}

// MARK: - PreferenceKey для передачи размера
struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func saveSize(
        in size: Binding<CGSize>
    ) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

// Пример
// Text("Some text").saveSize(in: $bindCGSize)

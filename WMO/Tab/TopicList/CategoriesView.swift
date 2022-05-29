//
//  CategoriesView.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import SwiftUI
import ComposableArchitecture

private let categoriesSpacing: CGFloat = 5
private let categoriespadding: CGFloat = 10
private let categoryFontSize: CGFloat = 13
private let categoryTextPadding = EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
private let categoryBackgroundOpacity: CGFloat = 0.25
private let categoryCornerRadius: CGFloat = 16
private let categoryBorderWidth: CGFloat = 1.5

struct CategoriesView: View {
    let store: Store<CategoryState, CategoryAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            makeScrollView(viewStore.categories)
                .onAppear {
                    viewStore.send(.refresh)
                }
        }
    }
    
    func makeScrollView(_ categories: [CategoryList.Category]) -> some View {
        var scrollView = ScrollView(.horizontal) {
            HStack(spacing: categoriesSpacing) {
                ForEach(categories, id: \.id) { cat in
                    category(cat.name, color: cat.color, selected: false)
                }
            }
            .padding([.leading, .trailing], categoriespadding)
        }
        scrollView.showsIndicators = false
        return scrollView
    }
    
    private func category(_ title: String, color: String, selected: Bool) -> some View {
        let tint = Color(hex: color)
        let trimmedTitle = title.components(separatedBy: .init(charactersIn: " (（")).first ?? title
        return Text(trimmedTitle)
            .font(.system(size: categoryFontSize))
            .foregroundColor(tint)
            .padding(categoryTextPadding)
            .background(tint.opacity(categoryBackgroundOpacity))
            .overlay(
                RoundedRectangle(cornerRadius: categoryCornerRadius)
                    .stroke(tint, lineWidth: selected ? categoryBorderWidth : 0)
            )
            .cornerRadius(categoryCornerRadius)
        
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//
//  CategoriesView.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import SwiftUI

extension View {
    func hud<Content: View>(isPresented: Binding<Bool?>, @ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented.wrappedValue == true {
                content()
                    .padding(.horizontal, 12)
                    .padding(16)
                    .background(
                        Capsule()
                            .foregroundColor(Color.white)
                            .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
                    )
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }.zIndex(1)
            }
        } // ZSstack
    }
}


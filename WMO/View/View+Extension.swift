//
//  View+Extension.swift
//  WMO
//
//  Created by weijia on 2022/6/22.
//

import SwiftUI

extension View {
    @ViewBuilder
    func center<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let view = HStack(alignment: .center) {
            Spacer()
            content()
            Spacer()
        }
        if #available(iOS 15.0, *) {
            view.listRowSeparator(.hidden)
        } else {
            view
        }
    }
}

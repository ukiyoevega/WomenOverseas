//
//  LatestView.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import SwiftUI

struct TopicList: View {
    var body: some View {
        Text("Topics")
    }
}

struct LatestView: View {
    @StateObject private var selectedMenu = CategoriesSelectedMenuStore(selectedMenu: CategoriesMenu.allCases.first!)

    var body: some View {
        NavigationView {
            Group {
                TabView(selection: $selectedMenu.menu) {
                    ForEach(CategoriesMenu.allCases, id: \.self) { menu in
                        TopicList().tag(menu)
                    }
                }
//                .tabViewStyle(DefaultTabViewStyle())
            }
        }
    }
}


#if DEBUG
struct LatestView_Previews : PreviewProvider {
    static var previews: some View {
        LatestView()
    }
}
#endif

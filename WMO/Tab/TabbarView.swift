//
//  TabbarView.swift
//  WMO
//
//  Created by weijia on 2022/4/21.
//

import SwiftUI

struct TabbarView: View {
    @State var selectedTab = Tab.latest
    let link: String?

    enum Tab {
        case home
        case latest
        case discover
        case me
    }
    
    private func tabbarItem(text: String, image: String) -> some View {
        VStack {
            Image(systemName: image).imageScale(.large)
                .foregroundColor(Color("button_pink", bundle: nil))
            Text(text).foregroundColor(Color("button_pink", bundle: nil))
        }
    }
    
    private func url(_ string: String) -> URL {
        return URL(string: string) ?? URL(string: "womenoverseas.com")!
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Webview(url: url("https://womenoverseas.com"), sedKey: nil).tabItem {
                self.tabbarItem(text: "Home", image: "house.fill")
            }.tag(Tab.home)
            Webview(url: url(self.link ?? "https://womenoverseas.com/latest"), sedKey: nil).tabItem {
                self.tabbarItem(text: "Latest", image: "square.stack.fill")
            }.tag(Tab.latest)
            Webview(url: url("https://womenoverseas.com/tag/%E7%B2%BE%E5%8D%8E%E8%B4%B4"), sedKey: nil).tabItem {
                self.tabbarItem(text: "Featured", image: "star.circle")
            }.tag(Tab.discover)
            Webview(url: url("https://womenoverseas.com/upcoming-events"), sedKey: nil).tabItem {
                self.tabbarItem(text: "Events", image: "calendar")
            }.tag(Tab.me)
        }.foregroundColor(Color("button_pink", bundle: nil))
    }
}

#if DEBUG
struct TabbarView_Previews : PreviewProvider {
    static var previews: some View {
        TabbarView(link: nil)
    }
}
#endif

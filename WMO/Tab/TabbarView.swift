//
//  TabbarView.swift
//  WMO
//
//  Created by weijia on 2022/4/21.
//

import SwiftUI
import Combine
import ComposableArchitecture

extension Notification.Name {
    static let triggerScrollToTopAndRefresh = Notification.Name(rawValue: "com.womenoverseas.webview.triggerScrollToTopAndRefresh")
}

struct TabbarView: View {
    @State var selectedTab: Tab
    @State var shouldPresentLink: Bool = false
    let link: String?

    init(tab: Tab, link: String? = nil) {
        self.selectedTab = tab
        self.link = link
//        self.setupApperance()
    }
    
    enum Tab: Equatable {
        case home
        case latest
        case featured
        case event
        case none
    }
    
    private func tabbarItem(text: String, image: String) -> some View {
        VStack {
            Image(systemName: image).imageScale(.large)
                .foregroundColor(Color("header_pink", bundle: nil))
            Text(text).foregroundColor(Color("header_pink", bundle: nil))
        }
    }
//    let statusBarModifier = NavigationBarModifier(backgroundColor: UIColor(named: "header_pink") ?? .white, textColor: .white)

    private func url(_ string: String?) -> URL {
        if let urlString = string, let url = URL(string: urlString) {
            return url
        }
        return URL(string: "womenoverseas.com/404")!
    }
    
    var body: some View {
        let selection = Binding<Tab>(
            get: { self.selectedTab },
            set: {
                if (self.selectedTab == $0) {
                    NotificationCenter.default.post(name: .triggerScrollToTopAndRefresh, object: nil, userInfo: ["tab": self.selectedTab])
                }
                self.selectedTab = $0
            })
        
        return ZStack {
            TabView(selection: selection) {
                TopicListView(store: Store(initialState: TopicState(),
                                           reducer: topicReducer,
                                           environment: TopicEnvironment()))
//                Webview(type: .home,
//                        url: url("https://womenoverseas.com"))
                    .tabItem {
                        self.tabbarItem(text: "Home", image: "house.fill")
                    }.tag(Tab.home)
                Webview(type: .latest,
                        url: url("https://womenoverseas.com/latest"))
                    .tabItem {
                        self.tabbarItem(text: "Latest", image: "square.stack.fill")
                    }.tag(Tab.latest)
                Webview(type: .featured,
                        url: url("https://womenoverseas.com/tag/%E7%B2%BE%E5%8D%8E%E8%B4%B4"))
                    .tabItem {
                        self.tabbarItem(text: "Featured", image: "star.circle")
                    }.tag(Tab.featured)
                Webview(type: .event,
                        url: url("https://womenoverseas.com/upcoming-events"))
                    .tabItem {
                        self.tabbarItem(text: "Events", image: "calendar")
                    }.tag(Tab.event)
            }
            .foregroundColor(Color("button_pink", bundle: nil))
//            .modifier(statusBarModifier)
            .onAppear(perform: {
                if let link = link, let _ = URL(string: link) {
                    self.shouldPresentLink = true
                }
            })
            .sheet(isPresented: $shouldPresentLink) {
                // on dismiss
            } content: {
                Webview(type: .event, url: url(link))
            }

        }
    }
}

#if DEBUG
struct TabbarView_Previews : PreviewProvider {
    static var previews: some View {
        TabbarView(tab: .home, link: nil)
    }
}
#endif


struct NavigationBarModifier: ViewModifier {
    
  var backgroundColor: UIColor
  var textColor: UIColor

  init(backgroundColor: UIColor, textColor: UIColor) {
    // assign
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    // configure
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithTransparentBackground()
    coloredAppearance.backgroundColor = .clear
    coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
    coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
    // change appearance
    UINavigationBar.appearance().standardAppearance = coloredAppearance
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    UINavigationBar.appearance().tintColor = textColor
  }

  func body(content: Content) -> some View {
    ZStack{
       content
        VStack {
          GeometryReader { geometry in
              Color(backgroundColor) // This is Color so we can reference frame
                .frame(height: geometry.safeAreaInsets.top)
                .edgesIgnoringSafeArea(.top)
              Spacer()
          }
        }
     }
  }
    
}

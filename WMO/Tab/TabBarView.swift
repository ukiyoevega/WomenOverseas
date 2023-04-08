//
//  TabbarView.swift
//  WMO
//
//  Created by weijia on 2022/5/31.
//

import SwiftUI
import Combine
import ComposableArchitecture

extension Notification.Name {
    static let triggerScrollToTopAndRefresh = Notification.Name(rawValue: "com.womenoverseas.webview.triggerScrollToTopAndRefresh")
}

/// refactor done here: replace navigationView-style tabs with plainView-style tabs inside a container navigation view
struct TabBarView : View {
    @State var selectedTab: Tab = .home
    @State var shouldPresentLink: Bool = false

    let link: String?

    init(selectedTab: Tab, link: String? = nil) {
        self.selectedTab = selectedTab
        self.link = link
        self.setupAppearance()
    }

    let topicList = TopicListView(store: Store(initialState: TopicState(),
                                                   reducer: topicReducer,
                                                   environment: TopicEnvironment()))
    let latestWeb = Webview(type: .latest,
                            url: "https://womenoverseas.com/latest", secKey: nil)
    let eventsWeb = Webview(type: .events,
                            url: "https://womenoverseas.com/upcoming-events", secKey: nil)
    let profile = ProfileView(store: Store(initialState: ProfileState(),
                                               reducer: profileReducer, environment: ()))
    let statusBarModifier = NavigationBarModifier(backgroundColor: UIColor(named: "header_pink"), textColor: .white)

    var body: some View {
        
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .home: topicList
                    case .latest: latestWeb
                            .modifier(statusBarModifier)
                            .navigationBarHidden(true)
                    case .events: eventsWeb
                            .modifier(statusBarModifier)
                            .navigationBarHidden(true)
                    case .profile: profile
                    }
                }
                TabBar(selectedIndex: Binding<Tab>(
                    get: { self.selectedTab },
                    set: {
                        if (self.selectedTab == $0) {
                            NotificationCenter.default.post(name: .triggerScrollToTopAndRefresh, object: nil, userInfo: ["tab": self.selectedTab])
                        }
                        self.selectedTab = $0
                    }))
            }
            .edgesIgnoringSafeArea(.bottom)
            .foregroundColor(Color.accentForeground)
            .onAppear(perform: {
                if let link = link, let _ = URL(string: link) {
                    self.shouldPresentLink = true
                }
            })
            .sheet(isPresented: $shouldPresentLink) {
            } content: {
                if let link = link {
                    Webview(type: .events, url: link, secKey: nil)
                }
            }
        }
        .accentColor(Color.mainIcon) // webview loading color
    }

    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor(hex: "D8805E") // mainIcon
    }
}

// MARK: - TabBar

struct TabBar: View {
    @Binding var selectedIndex: Tab

    var body: some View {
        HStack(alignment: .bottom) {
            ForEach(Tab.allCases) { tab in
                Button(action: {
                    self.selectedIndex = tab
                }) {
                    TabBarItem(selected: $selectedIndex, thisTab: tab)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 0)
        )
    }
}

struct TabBarItem: View {
    @Binding var selected : Tab
    let thisTab: Tab

    var body: some View {
        VStack() {
            Image(systemName: thisTab.icon)
                .imageScale(.large)
                .foregroundColor(selected == thisTab ? Color.mainIcon : Color.gray)
            Text(thisTab.title)
                .foregroundColor(selected == thisTab ? Color.mainIcon : Color.gray)
                .font(.system(size: 9))
        }.padding(EdgeInsets(top: 2, leading: 0, bottom: 20, trailing: 0))
    }
}

enum Tab: Int, CaseIterable, Identifiable {
    var id: String { "\(self.rawValue)" }

    case home = 0, latest, events, profile

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .latest:
            return "Latest"
        case .events:
            return "Events"
        case .profile:
            return "Me"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .latest:
            return "square.stack.fill"
        case .events:
            return "calendar"
        case .profile:
            return "person.fill"
        }
    }
}

#if DEBUG
struct TabbarView_Previews : PreviewProvider {
    static var previews: some View {
        TabBarView(selectedTab: .home, link: nil)
    }
}
#endif

struct NavigationBarModifier: ViewModifier {

    var backgroundColor: UIColor?
    var textColor: UIColor?

    init(backgroundColor: UIColor?, textColor: UIColor?) {
        // assign
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        // configure
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .white
        if let textColor = self.textColor {
            coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
            coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        }
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
                    Color(backgroundColor ?? .white) // This is Color so we can reference frame
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }

}

//
//  CategoriesMenu.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation

enum CategoriesMenu: Int, CaseIterable {
    case nowPlaying, upcoming, trending, popular, topRated, genres
    
    func title() -> String {
        switch self {
        case .popular: return "Popular"
        case .topRated: return "Top Rated"
        case .upcoming: return "Upcoming"
        case .nowPlaying: return "Now Playing"
        case .trending: return "Trending"
        case .genres: return "Genres"
        }
    }
    
//    func endpoint() -> APIService.Endpoint {
//        switch self {
//        case .popular: return APIService.Endpoint.popular
//        case .topRated: return APIService.Endpoint.topRated
//        case .upcoming: return APIService.Endpoint.upcoming
//        case .nowPlaying: return APIService.Endpoint.nowPlaying
//        case .trending: return APIService.Endpoint.trending
//        case .genres: return APIService.Endpoint.genres
//        }
//    }
}

class MoviesPagesListener {
    var currentPage: Int = 1 {
        didSet {
            loadPage()
        }
    }
    
    func loadPage() {
        
    }
}

final class CategoriesMenuListPageListener: MoviesPagesListener {
    var menu: CategoriesMenu {
        didSet {
            currentPage = 1
        }
    }
    
    override func loadPage() {
//        store.dispatch(action: MoviesActions.FetchCategoriesMenuList(list: menu, page: currentPage))
    }
    
    init(menu: CategoriesMenu, loadOnInit: Bool? = true) {
        self.menu = menu
        
        super.init()
        
        if loadOnInit == true {
            loadPage()
        }
    }
}

final class CategoriesSelectedMenuStore: ObservableObject {
    let pageListener: CategoriesMenuListPageListener
    
    @Published var menu: CategoriesMenu {
        didSet {
            pageListener.menu = menu
        }
    }
        
    init(selectedMenu: CategoriesMenu) {
        self.menu = selectedMenu
        self.pageListener = CategoriesMenuListPageListener(menu: selectedMenu)
    }
}

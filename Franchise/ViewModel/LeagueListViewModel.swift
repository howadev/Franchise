//
//  LeagueListViewModel.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-14.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

/// The view model for `LeagueListViewController`.
final class LeagueListViewModel {
    private enum Constants {
        static let throttleInterval: TimeInterval = 0.5
    }
    
    let title: String
    
    let loaded: Property<Loaded<OnceLoaded>>
    
    let reload: Action<(), (), NoError>
    
    private let contentSource: ContentSource<Loaded<OnceLoaded>>
    
    init(provider: LeagueListViewModelProviderProtocol) {
        title = NSLocalizedString("Leagues", comment: "")

        let fetchLeagues = provider.fetchLeagues()
            .skipRepeats()
            .valuesAsProperty()
        
        let source = fetchLeagues
            .map { OnceLoaded(provider: provider, leagues: $0) }
            .toLoaded(UserError.init)
        
        contentSource = ContentSource(source: source)
        loaded = Property(initial: .loading, then: contentSource.values)
        reload = contentSource.reload
    }
    
    func viewDidLoad() {
        contentSource.load()
    }
}

extension LeagueListViewModel {
    /// The view model for `LeagueListContentViewController`.
    final class OnceLoaded {
        let leagues: Property<[League]>
        
        let selectLeague: Action<League, TeamListViewModel, NoError>
        
        let filterLeague: Action<String?, String, NoError>
        
        init(provider: LeagueListViewModelProviderProtocol,
             leagues: Property<[League]>) {
            
            self.filterLeague = Action { SignalProducer(value: $0 ?? "") }
            let filterLeagueValues = filterLeague.values
                .throttle(Constants.throttleInterval, on: QueueScheduler.main)
            let filter = Property(initial: "", then: filterLeagueValues)
                .skipRepeats()
            
            self.leagues = leagues.combineLatest(with: filter)
                .map { leagues, filter in
                    let sortedLeagues = leagues.sorted { $0.fullName < $1.fullName }
                    if filter.isEmpty {
                        return sortedLeagues
                    } else {
                        return sortedLeagues
                            .filter { league in
                                league.fullName.lowercased().contains(filter.lowercased())
                                    || league.slug.lowercased().contains(filter.lowercased())
                            }
                    }
                }
            
            self.selectLeague = Action { league in
                SignalProducer(value: provider.makeTeamListViewModel(league: league))
            }
        }
    }
}

protocol LeagueListViewModelProviderProtocol {
    func fetchLeagues() -> SignalProducer<[League], APIError>
    func makeTeamListViewModel(league: League) -> TeamListViewModel
}

struct LeagueListViewModelProvider: LeagueListViewModelProviderProtocol {
    func fetchLeagues() -> SignalProducer<[League], APIError> {
        guard let url = URL(string: "https://raw.githubusercontent.com/scoremedia/league-navigator/master/leagues.json") else {
            return SignalProducer(error: .invalidURL)
        }
        
        let request = URLRequest(url: url)
        return URLSession.shared.reactive.data(with: request)
            .mapError { _ in APIError.networkError }
            .flatMap(.latest) { data, response -> SignalProducer<[League], APIError> in
                if let leagues = try? JSONDecoder().decode([League].self, from: data) {
                    return SignalProducer(value: leagues)
                } else {
                    return SignalProducer(error: APIError.invalidResponse)
                }
            }
    }
    
    func makeTeamListViewModel(league: League) -> TeamListViewModel {
        return TeamListViewModel(provider: TeamListViewModelProvider(),
                                 league: league)
    }
}

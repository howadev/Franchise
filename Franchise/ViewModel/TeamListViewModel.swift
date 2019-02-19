//
//  TeamListViewModel.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-17.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

/// The view model for `TeamListViewController`.
final class TeamListViewModel {
    private enum Constants {
        static let throttleInterval: TimeInterval = 0.5
    }
    
    let title: String
    
    let loaded: Property<Loaded<OnceLoaded>>
    
    let reload: Action<(), (), NoError>
    
    private let contentSource: ContentSource<Loaded<OnceLoaded>>
    
    init(provider: TeamListViewModelProviderProtocol,
         league: League) {
        title = league.fullName
        
        let fetchTeams = provider.fetchTeams(leagueSlug: league.slug)
            .skipRepeats()
            .valuesAsProperty()
        
        let source = fetchTeams
            .map(OnceLoaded.init)
            .toLoaded(UserError.init)
        
        contentSource = ContentSource(source: source)
        loaded = Property(initial: .loading, then: contentSource.values)
        reload = contentSource.reload
    }
    
    func viewDidLoad() {
        contentSource.load()
    }
}

extension TeamListViewModel {
    /// The view model for `TeamListContentViewController`.
    final class OnceLoaded {
        let teams: Property<[Team]>
        
        let filterTeam: Action<String?, String, NoError>
        
        init(teams: Property<[Team]>) {
            self.filterTeam = Action { SignalProducer(value: $0 ?? "") }
            let filterTeamValues = filterTeam.values
                .throttle(Constants.throttleInterval, on: QueueScheduler.main)
            let filter = Property(initial: "", then: filterTeamValues)
                .skipRepeats()
            
            self.teams = teams.combineLatest(with: filter)
                .map { teams, filter in
                    if filter.isEmpty {
                        return teams
                    } else {
                        return teams
                            .filter { team in
                                team.fullName.lowercased().contains(filter.lowercased())
                                    || team.name.lowercased().contains(filter.lowercased())
                                    || team.location?.lowercased().contains(filter.lowercased()) ?? false
                        }
                    }
                }
        }
    }
}

protocol TeamListViewModelProviderProtocol {
    func fetchTeams(leagueSlug: String) -> SignalProducer<[Team], APIError>
}

struct TeamListViewModelProvider: TeamListViewModelProviderProtocol {
    func fetchTeams(leagueSlug: String) -> SignalProducer<[Team], APIError> {
        guard let url = URL(string: "https://raw.githubusercontent.com/scoremedia/league-navigator/master/leagues/\(leagueSlug).json") else {
            return SignalProducer(error: .invalidURL)
        }
        
        let request = URLRequest(url: url)
        return URLSession.shared.reactive.data(with: request)
            .mapError { _ in APIError.networkError }
            .flatMap(.latest) { data, response -> SignalProducer<[Team], APIError> in
                if let leagues = try? JSONDecoder().decode([Team].self, from: data) {
                    return SignalProducer(value: leagues)
                } else {
                    return SignalProducer(error: APIError.invalidResponse)
                }
            }
    }
}

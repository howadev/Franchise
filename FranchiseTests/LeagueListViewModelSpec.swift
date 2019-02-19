//
//  LeagueListViewModelSpec.swift
//  FranchiseTests
//
//  Created by Haohua Li on 2019-02-18.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation
import Nimble
import Quick
import ReactiveSwift
import Result
@testable import Franchise

internal final class LeagueListViewModelSpec: QuickSpec {
    override func spec() {
        describe("LeagueListViewModel") {
            var mockProvider: TestLeagueListViewModelProvider!
            var mainVM: LeagueListViewModel!
            
            beforeEach {
                mockProvider = TestLeagueListViewModelProvider()
                mainVM = LeagueListViewModel(provider: mockProvider)
                mainVM.viewDidLoad()
                
                expect(mainVM.loaded).to(satisfy { $0.isLoading })
            }
            
            context("Loading Lifecycle") {
                it("should fail to load if there is an error when fetching leagues") {
                    expect(mainVM.loaded).to(satisfy { $0.isLoading })
                    
                    mockProvider.mockFetchLeagues.input.send(error: .invalidURL)
                    expect(mainVM.loaded).to(satisfy { $0.isFailed })
                }
                
                it("should be able to reload after failure") {
                    expect(mainVM.loaded).to(satisfy { $0.isLoading })
                    
                    mockProvider.mockFetchLeagues.input.send(error: .invalidURL)
                    expect(mainVM.loaded).to(satisfy { $0.isFailed })
                    
                    mockProvider.mockFetchLeagues = Signal<[League], APIError>.pipe()
                    mainVM.reload.apply().start()
                    expect(mainVM.loaded).to(satisfy { $0.isLoading })
                    
                    mockProvider.sendInitialValues()
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                }
                
                it("should load successfully after fetching leagues") {
                    expect(mainVM.loaded).to(satisfy { $0.isLoading })
                    
                    mockProvider.sendInitialValues()
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                }
            }
            
            context("Properties") {
                it("should have correct `title`") {
                    expect(mainVM.title) == "Leagues"
                }
            }
            
            context("OnceLoaded") {
                it("should have correct `leagues`") {
                    mockProvider.mockFetchLeagues.input.send(value: [Template.league1, Template.league2])
                    expect(mainVM.loaded).to(satisfy { $0.isDone })

                    guard let onceLoaded = mainVM.loaded.value.value else { return fail() }
                    expect(onceLoaded.leagues).to(satisfy { $0 == [Template.league2, Template.league1] })
                    
                    mockProvider.mockFetchLeagues.input.send(value: [Template.league1])
                    expect(onceLoaded.leagues).to(satisfy { $0 == [Template.league1] })
                }
                
                it("should have functional `filterLeague`") {
                    mockProvider.mockFetchLeagues.input.send(value: [Template.league1, Template.league2])
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                    
                    guard let onceLoaded = mainVM.loaded.value.value else { return fail() }
                    
                    var values = [String]()
                    onceLoaded.filterLeague.values
                        .observeValues { value in
                            values.append(value)
                        }
                    
                    expect(values.isEmpty) == true
                    
                    onceLoaded.filterLeague.apply(nil).start()
                    expect(values.count) == 1
                    expect(values.last) == ""
                    
                    onceLoaded.filterLeague.apply("basket").start()
                    expect(values.count) == 2
                    expect(values.last) == "basket"
                }
                
                it("should sort `leagues` by their `fullName`") {
                    let sortedLeagues = "abcdefghijklmnopqrstuvwxyz"
                        .map { League(fullName: String($0), slug: "slug\($0)") }
                    let shuffledLeagues = sortedLeagues.shuffled()
                    expect(sortedLeagues) != shuffledLeagues
                    
                    mockProvider.mockFetchLeagues.input.send(value: shuffledLeagues)
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                    
                    guard let onceLoaded = mainVM.loaded.value.value else { return fail() }
                    expect(onceLoaded.leagues).to(satisfy { $0 == sortedLeagues})
                }
                
                it("should filter `leagues` by their `fullName` or `slug`") {
                    mockProvider.mockFetchLeagues.input.send(value: [Template.league1, Template.league2, Template.league3])
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                    
                    guard let onceLoaded = mainVM.loaded.value.value else { return fail() }
                    expect(onceLoaded.leagues).to(satisfy { $0 == [Template.league2, Template.league3, Template.league1] })
                    
                    onceLoaded.filterLeague.apply("league").start()
                    expect(onceLoaded.leagues).toEventually(satisfy { $0 == [Template.league3, Template.league1] })
                    
                    onceLoaded.filterLeague.apply("3").start()
                    expect(onceLoaded.leagues).toEventually(satisfy { $0 == [Template.league2, Template.league3] })
                    
                    onceLoaded.filterLeague.apply(nil).start()
                    expect(onceLoaded.leagues).toEventually(satisfy { $0 == [Template.league2, Template.league3, Template.league1] })
                }

                it("should have functional `selectLeague`") {
                    mockProvider.sendInitialValues()
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                    
                    guard let onceLoaded = mainVM.loaded.value.value else { return fail() }
                    
                    var values = [TeamListViewModel]()
                    onceLoaded.selectLeague.values
                        .observeValues { value in
                            values.append(value)
                        }
                    
                    expect(values.isEmpty) == true
                    onceLoaded.selectLeague.apply(Template.league1).start()
                    expect(values.count) == 1
                    expect(values.last?.title) == Template.league1.fullName
                }
            }
        }
    }
}

final class TestLeagueListViewModelProvider: LeagueListViewModelProviderProtocol {
    func sendInitialValues() {
        mockFetchLeagues.input.send(value: [Template.league1, Template.league2])
    }
    
    var mockFetchLeagues = Signal<[League], APIError>.pipe()
    
    func fetchLeagues() -> SignalProducer<[League], APIError> {
        return SignalProducer<[League], APIError> { [weak self] observer, _ in
            guard let self = self else {
                observer.sendInterrupted()
                return
            }
            
            self.mockFetchLeagues.output.observe(observer)
        }
    }
    
    func makeTeamListViewModel(league: League) -> TeamListViewModel {
        let provider = TestTeamListViewModelProvider()
        return TeamListViewModel(provider: provider, league: league)
    }
}

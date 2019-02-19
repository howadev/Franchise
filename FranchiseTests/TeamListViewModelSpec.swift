//
//  TeamListViewModelSpec.swift
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

internal final class TeamListViewModelSpec: QuickSpec {
    override func spec() {
        describe("TeamListViewModel") {
            var mockProvider: TestTeamListViewModelProvider!
            var mainVM: TeamListViewModel!
            
            beforeEach {
                mockProvider = TestTeamListViewModelProvider()
                mainVM = TeamListViewModel(provider: mockProvider,
                                           league: Template.league1)
                mainVM.viewDidLoad()
                
                expect(mainVM.loaded).to(satisfy { $0.isLoading })
            }
            
            context("Loading Lifecycle") {
                it("should fail to load if there is an error when fetching leagues") {
                    expect(mainVM.loaded).to(satisfy { $0.isLoading })
                    
                    mockProvider.mockFetchTeams.input.send(error: .invalidURL)
                    expect(mainVM.loaded).to(satisfy { $0.isFailed })
                }
                
                it("should be able to reload after failure") {
                    expect(mainVM.loaded).to(satisfy { $0.isLoading })
                    
                    mockProvider.mockFetchTeams.input.send(error: .invalidURL)
                    expect(mainVM.loaded).to(satisfy { $0.isFailed })
                    
                    mockProvider.mockFetchTeams = Signal<[Team], APIError>.pipe()
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
                    expect(mainVM.title) == Template.league1.fullName
                }
                
                it("should have functional `filterTeam`") {
                    var values = [String]()
                    mainVM.filterTeam.values
                        .observeValues { value in
                            values.append(value)
                    }
                    
                    expect(values.isEmpty) == true
                    
                    mainVM.filterTeam.apply(nil).start()
                    expect(values.count) == 1
                    expect(values.last) == ""
                    
                    mainVM.filterTeam.apply("basket").start()
                    expect(values.count) == 2
                    expect(values.last) == "basket"
                }
            }
            
            context("OnceLoaded") {
                it("should have correct `teams`") {
                    mockProvider.mockFetchTeams.input.send(value: [Template.team1, Template.team2])
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                    
                    guard let onceLoaded = mainVM.loaded.value.value else { return fail() }
                    expect(onceLoaded.teams).to(satisfy { $0 == [Template.team1, Template.team2] })
                    
                    mockProvider.mockFetchTeams.input.send(value: [Template.team1])
                    expect(onceLoaded.teams).to(satisfy { $0 == [Template.team1] })
                }
                
                it("should filter `teams` by their `fullName`, `name`, or `location`") {
                    mockProvider.mockFetchTeams.input.send(value: [Template.team1, Template.team2, Template.team3, Template.team4])
                    expect(mainVM.loaded).to(satisfy { $0.isDone })
                    
                    guard let onceLoaded = mainVM.loaded.value.value else { return fail() }
                    expect(onceLoaded.teams).to(satisfy { $0 == [Template.team1, Template.team2, Template.team3, Template.team4] })
                    
                    mainVM.filterTeam.apply("name").start()
                    expect(onceLoaded.teams).toEventually(satisfy { $0 == [Template.team1, Template.team2] })
                    
                    mainVM.filterTeam.apply("full").start()
                    expect(onceLoaded.teams).toEventually(satisfy { $0 == [Template.team1, Template.team3] })
                    
                    mainVM.filterTeam.apply("location").start()
                    expect(onceLoaded.teams).toEventually(satisfy { $0 == [Template.team1, Template.team4] })
                    
                    mainVM.filterTeam.apply("team").start()
                    expect(onceLoaded.teams).toEventually(satisfy { $0 == [Template.team1, Template.team2, Template.team3, Template.team4] })
                    
                    mainVM.filterTeam.apply(nil).start()
                    expect(onceLoaded.teams).toEventually(satisfy { $0 == [Template.team1, Template.team2, Template.team3, Template.team4] })
                }
            }
        }
    }
}

final class TestTeamListViewModelProvider: TeamListViewModelProviderProtocol {
    func sendInitialValues() {
        mockFetchTeams.input.send(value: [])
    }
    
    var mockFetchTeams = Signal<[Team], APIError>.pipe()
    
    func fetchTeams(leagueSlug: String) -> SignalProducer<[Team], APIError> {
        return SignalProducer<[Team], APIError> { [weak self] observer, _ in
            guard let self = self else {
                observer.sendInterrupted()
                return
            }
            
            self.mockFetchTeams.output.observe(observer)
        }
    }
}

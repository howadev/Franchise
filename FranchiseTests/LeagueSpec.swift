//
//  LeagueSpec.swift
//  FranchiseTests
//
//  Created by Haohua Li on 2019-02-18.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Nimble
import Quick
@testable import Franchise

class LeagueSpec: QuickSpec {
    override func spec() {
        describe("League") {
            context("decoding") {
                it("should decode successfully with preferred JSON") {
                    let json: [String: Any] = [
                        "full_name": "NBA Basketbal",
                        "slug": "nba"
                    ]
                    guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
                        return fail()
                    }
                    guard let league = try? JSONDecoder().decode(League.self, from: data) else {
                        return fail()
                    }
                    expect(league.fullName) == "NBA Basketbal"
                    expect(league.slug) == "nba"
                }
            }
        }
    }
}

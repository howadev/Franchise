//
//  TeamSpec.swift
//  FranchiseTests
//
//  Created by Haohua Li on 2019-02-18.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Nimble
import Quick
@testable import Franchise

class TeamSpec: QuickSpec {
    override func spec() {
        describe("Team") {
            context("decoding") {
                it("should decode successfully with preferred JSON") {
                    let json: [String: Any] = [
                        "location" : "Toronto",
                        "full_name" : "Toronto Raptors",
                        "logo" : "https://d12smlnp5321d2.cloudfront.net/basketball/team/5/logo.png",
                        "colour_2" : "343434",
                        "name" : "Raptors",
                        "colour_1" : "CE1141"
                    ]
                    guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
                        return fail()
                    }
                    guard let team = try? JSONDecoder().decode(Team.self, from: data) else {
                        return fail()
                    }
                    expect(team.fullName) == "Toronto Raptors"
                    expect(team.name) == "Raptors"
                    expect(team.location) == "Toronto"
                    expect(team.logoURL?.absoluteString) == "https://d12smlnp5321d2.cloudfront.net/basketball/team/5/logo.png"
                    expect(team.color) == UIColor(hex: "CE1141")
                }
                
                it("should decode successfully without `location`") {
                    let json: [String: Any] = [
                        "full_name" : "Toronto Raptors",
                        "logo" : "https://d12smlnp5321d2.cloudfront.net/basketball/team/5/logo.png",
                        "colour_2" : "343434",
                        "name" : "Raptors",
                        "colour_1" : "CE1141"
                    ]
                    guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
                        return fail()
                    }
                    guard let team = try? JSONDecoder().decode(Team.self, from: data) else {
                        return fail()
                    }
                    expect(team.fullName) == "Toronto Raptors"
                    expect(team.name) == "Raptors"
                    expect(team.location).to(beNil())
                    expect(team.logoURL?.absoluteString) == "https://d12smlnp5321d2.cloudfront.net/basketball/team/5/logo.png"
                    expect(team.color) == UIColor(hex: "CE1141")
                }
                
                it("should decode successfully without `logo`") {
                    let json: [String: Any] = [
                        "full_name" : "Toronto Raptors",
                        "colour_2" : "343434",
                        "name" : "Raptors",
                        "colour_1" : "CE1141"
                    ]
                    guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
                        return fail()
                    }
                    guard let team = try? JSONDecoder().decode(Team.self, from: data) else {
                        return fail()
                    }
                    expect(team.fullName) == "Toronto Raptors"
                    expect(team.name) == "Raptors"
                    expect(team.location).to(beNil())
                    expect(team.logoURL).to(beNil())
                    expect(team.color) == UIColor(hex: "CE1141")
                }
                
                it("should decode successfully without `colour_1`") {
                    let json: [String: Any] = [
                        "full_name" : "Toronto Raptors",
                        "name" : "Raptors",
                        "colour_2" : "343434"
                    ]
                    guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
                        return fail()
                    }
                    guard let team = try? JSONDecoder().decode(Team.self, from: data) else {
                        return fail()
                    }
                    expect(team.fullName) == "Toronto Raptors"
                    expect(team.name) == "Raptors"
                    expect(team.location).to(beNil())
                    expect(team.logoURL).to(beNil())
                    expect(team.color).to(beNil())
                }
            }
        }
    }
}

//
//  UnitTestHelper.swift
//  FranchiseTests
//
//  Created by Haohua Li on 2019-02-18.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation
import Nimble
import Quick
import ReactiveSwift
@testable import Franchise

enum Template {
    static let league1 = League(fullName: "NBA G League", slug: "gleague")
    static let league2 = League(fullName: "BIG3", slug: "big3")
    static let league3 = League(fullName: "CBA League", slug: "cba3")
    
    static let team1 = Team(name: "team-name-1",
                            fullName: "team-full-1",
                            location: "team-location-1",
                            logoURL: nil,
                            color: nil)
    
    static let team2 = Team(name: "team-name-2",
                            fullName: "",
                            location: nil,
                            logoURL: nil,
                            color: nil)
    
    static let team3 = Team(name: "",
                            fullName: "team-full-3",
                            location: nil,
                            logoURL: nil,
                            color: nil)
    
    static let team4 = Team(name: "",
                            fullName: "",
                            location: "team-location-4",
                            logoURL: nil,
                            color: nil)
}

func satisfy<Property: PropertyProtocol, Value>(_ predicate: @escaping (Value) -> Bool) -> Predicate<Property> where Property.Value == Value {
    let errorMessage = "have value satisifying the predicate"
    return Predicate.define(errorMessage) { expression, msg in
        if let property = try expression.evaluate() {
            return PredicateResult(bool: predicate(property.value), message: .expectedCustomValueTo(errorMessage, stringify(property.value)))
        } else {
            return PredicateResult(status: .fail, message: msg)
        }
    }
}

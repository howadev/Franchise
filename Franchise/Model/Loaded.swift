//
//  Loaded.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-14.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation

enum Loaded<Value> {
    case loading
    case done(Value)
    case failed(UserError)
    
    var value: Value? {
        switch self {
        case .done(let value):
            return value
        case .loading, .failed:
            return nil
        }
    }
    
    var error: UserError? {
        switch self {
        case .failed(let error):
            return error
        case .loading, .done:
            return nil
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .done, .failed:
            return false
        }
    }
    
    var isDone: Bool {
        switch self {
        case .done:
            return true
        case .loading, .failed:
            return false
        }
    }
    
    var isFailed: Bool {
        switch self {
        case .failed:
            return true
        case .loading, .done:
            return false
        }
    }
}

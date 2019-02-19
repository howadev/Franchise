//
//  UserError.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-14.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation

/// An error that could be presented to users.
struct UserError: Error, Equatable {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    init(_ error: APIError) {
        switch error {
        case .invalidURL:
            message = NSLocalizedString("Invalid URL", comment: "")
        case .networkError:
            message = NSLocalizedString("Network Error", comment: "")
        case .invalidResponse:
            message = NSLocalizedString("Invalid Response", comment: "")
        }
    }
}

//
//  APIError.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-18.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation

/// Internal errors about network requests.
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError
}

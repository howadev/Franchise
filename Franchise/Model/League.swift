//
//  League.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-13.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation

struct League: Equatable {
    let fullName: String
    let slug: String
    
    init(fullName: String, slug: String) {
        self.fullName = fullName
        self.slug = slug
    }
}

extension League: Decodable {
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case slug
    }
}

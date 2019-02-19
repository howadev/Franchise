//
//  Team.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-13.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import UIKit

struct Team: Equatable {
    let name: String
    let fullName: String
    
    let location: String?
    let logoURL: URL?
    let color: UIColor?
    
    init(name: String,
         fullName: String,
         location: String?,
         logoURL: URL?,
         color: UIColor?) {
        self.name = name
        self.fullName = fullName
        self.location = location
        self.logoURL = logoURL
        self.color = color
    }
}

extension Team: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        fullName = try values.decode(String.self, forKey: .fullName)
        
        location = try? values.decode(String.self, forKey: .location)
        logoURL = try? values.decode(URL.self, forKey: .logoURL)
        color = (try? values.decode(String.self, forKey: .color)).map(UIColor.init)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case location
        case logoURL = "logo"
        case color = "colour_1"
    }
}

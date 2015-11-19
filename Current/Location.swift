//
//  Location.swift
//  Current
//
//  Created by Chase Roossin on 11/19/15.
//  Copyright © 2015 RoossinEnterprise. All rights reserved.
//

import Foundation

class Location {
    //Properties of a Location
    var title: String
    var info: String
    var distance: Double
    var neighborhood: String
    var website: String
    var number: String

    init(title: String, info: String, distance: Double, neighborhood: String, website: String, number: String){
        self.title = title
        self.info = info
        self.distance = distance
        self.neighborhood = neighborhood
        self.website = website
        self.number = number
    }
}
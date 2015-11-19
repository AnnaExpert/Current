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
        self.distance = Double(round(1000*(distance*0.000621371192237))/100) //convert from meters to mi
        self.neighborhood = neighborhood
        self.website = website
        //Remove white space in tableview only when call to increase efficiency
        self.number = number
    }

    func debugLocation(){
        print("Name: \(title)\nInfo: \(info)\nDistance: \(distance)\nNeighborhoods: \(neighborhood)\nWebsite: \(website)\nNumber: \(number)\n")
    }
}
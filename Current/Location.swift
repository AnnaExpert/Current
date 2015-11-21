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
    var hours: [String]

    init(title: String, info: String, distance: Double, neighborhood: String, website: String, number: String, hours: [String]){
        self.title = title
        self.info = info
        self.distance = Double(round(1000*(distance*0.000621371192237))/100) //convert from meters to mi
        self.neighborhood = neighborhood
        self.website = website
        //Remove white space in tableview only when call to increase efficiency
        self.number = number
        self.hours = hours
    }

    //Determines if location is open currently
    func isOpen() -> Bool{
        let open = hours[0]
        let close = hours[1]

        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "k:mm"
        let timeZone = NSTimeZone(name: NSTimeZone.localTimeZone().abbreviation!)
        dateFormatter.timeZone=timeZone
        let openDate = dateFormatter.dateFromString(open)
        let closeDate = dateFormatter.dateFromString(close)

        let currentHour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        let openHour = NSCalendar.currentCalendar().component(.Hour, fromDate: openDate!)
        let closeHour = NSCalendar.currentCalendar().component(.Hour, fromDate: closeDate!)

        //If current hour is in between store hours return true
        if(currentHour > openHour && currentHour < closeHour){return true}

        return false
    }

    //Prints out info on given Location
    func debugLocation(){
        print("Name: \(title)\nInfo: \(info)\nDistance: \(distance)\nNeighborhoods: \(neighborhood)\nWebsite: \(website)\nNumber: \(number)\n")
    }
}
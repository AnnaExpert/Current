//
//  DateManager.swift
//  Current
//
//  Created by Chase Roossin on 11/20/15.
//  Copyright © 2015 RoossinEnterprise. All rights reserved.
//

import Foundation
import UIKit

class DateManager{
    class func todaysName() -> String{
        var todaysName : String
        let date = NSDate()
        let dayNumber = NSCalendar.currentCalendar().components(.Weekday, fromDate: date).weekday
        switch dayNumber {
        case 1: todaysName = "sunday"
        case 2: todaysName = "monday"
        case 3: todaysName = "tuesday"
        case 4: todaysName = "wednesday"
        case 5: todaysName = "thurday"
        case 6: todaysName = "friday"
        case 7: todaysName = "saturday"
        default: todaysName = "DAY ERROR"
        }
        return todaysName
    }
}
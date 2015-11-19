//
//  APIManager.swift
//  Current
//
//  Created by Chase Roossin on 11/19/15.
//  Copyright © 2015 RoossinEnterprise. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import SVProgressHUD

class APIManager{
    var locationManager: OneShotLocationManager?
    var allowedIDS = []

    //Attempting to graph locations from Current API
    func fetchLocations(callback:([Location])->()) {

        //Empty array to store all Locations
        var locations = [Location]()

        print("Attempting to Locate User")
        
        //Locate user
        locationManager = OneShotLocationManager()
        locationManager!.fetchWithCompletion {location, error in
            if location != nil {
                print("Received Location")

                //Saves location for API-Use
                let lat = location!.coordinate.latitude
                let lon = location!.coordinate.longitude
                print("lat: \(lat) lon: \(lon)")
                let location = Location(title: "Rubios", info: "Dinner", distance: 5.0, neighborhood: "Pelican", website: "www.google.com", number: "9495555555")
                let location2 = Location(title: "Chasers", info: "Dinner", distance: 5.0, neighborhood: "Pelican", website: "www.google.com", number: "9495555555")
                let location3 = Location(title: "Chasers", info: "Dinner", distance: 5.0, neighborhood: "Pelican", website: "www.google.com", number: "9495555555")
                locations.append(location)
                locations.append(location2)
                locations.append(location3)
                callback(locations)
            } else if error != nil {
                print("Error while fetching location:")
                SVProgressHUD.showErrorWithStatus("Can't get location")
                callback(locations)
            }
            self.locationManager = nil
        }
    }
}

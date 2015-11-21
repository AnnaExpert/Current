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
    var allowedIDS = [312, 313, 314, 315, 316, 338, 339, 340, 341,
                      342, 343, 344, 345, 346, 347, 348, 349, 350,
                      351, 352, 353, 354, 355, 356, 357, 358, 359,
                      360, 361, 362, 363, 364, 365, 366, 367, 368,
                      457, 458, 464]


    //Attempting to graph locations from Current API
    func fetchLocations(callback:([Location])->()) {

        //Determine day of week to use for getting hours
        let todaysName = DateManager.todaysName()

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

                //Get JSON data from file (waiting to get networking API right)
                DataManager.getDataFromJSON{ (data) -> Void in
                    let json = JSON(data: data)
                    //iterate through all locations
                    for i in 0...json["data"]["response"]["included_rows"].int! - 1{
                        //check that is an appropriate category ID
                        let locationCategoryID:[Int] = json["data"]["response"]["data"][i]["category_ids"].arrayValue.map { $0.int!}
                        if(locationCategoryID.contains(self.allowedIDS.contains)){
                            let locationName = json["data"]["response"]["data"][i]["name"].stringValue
                            let locationType = "Food and Dining" //Figure out a better way to take the array for display issues
                            let locationDistance = json["data"]["response"]["data"][i]["$distance"].doubleValue
                            let locationNeighborhood = json["data"]["response"]["data"][i]["neighborhood"][0].stringValue
                            let locationWebsite = json["data"]["response"]["data"][i]["website"].stringValue
                            let locationNumber = json["data"]["response"]["data"][i]["tel"].stringValue
                            let locationHours = json["data"]["response"]["data"][i]["hours"][todaysName][0].arrayObject as? [String] ?? ["00:00", "00:00"] //If no hours given for date set to not open
                            let locationLat = json["data"]["response"]["data"][i]["latitude"].stringValue
                            let locationLon = json["data"]["response"]["data"][i]["longitude"].stringValue
                            
                            let location = Location(title: locationName, info: locationType, distance: locationDistance, neighborhood: locationNeighborhood,
                                                    website: locationWebsite, number: locationNumber, lat: locationLat, lon: locationLon, hours: locationHours)
                            locations.append(location)
                        }
                    }
                    //Give back locations to LocationTableViewController
                    callback(locations)
                }
            } else if error != nil {
                print("Error while fetching location:")
                callback(locations)
            }
            self.locationManager = nil
        }
    }
}

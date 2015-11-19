//
//  LocationsTableViewController.swift
//  Current
//
//  Created by Chase Roossin on 11/18/15.
//  Copyright © 2015 RoossinEnterprise. All rights reserved.
//

import UIKit
import SVProgressHUD

class LocationsTableViewController: UITableViewController {

    let apiManager = APIManager()
    var neighborhoods = Dictionary<String, Array<Location>>()
    var sortedneighborhoods = [String]()

    override func viewDidLoad() {
        loadLocations()
    }
    override func viewDidAppear(animated: Bool) {
        SVProgressHUD.showWithStatus("Grabbing Locations")
    }

    //Gather array of Locations
    func loadLocations(){
        //Callback for putting received Data in the UI
        let refreshCallback: ([Location]) -> Void = { locations in

            //Checks for empty array and shows error message in case someting went wrong
            if locations.isEmpty {
                print("Returned an empty array...")
                SVProgressHUD.showErrorWithStatus("Couldn't get locations")
                return
            }
            print("Successfully returned data")

            //Sort locations based distance then put into correct neighborhood for table
            for location in locations.sort({ $0.distance < $1.distance }){
                //Grab neighborhood from current location
                var neighborhood = location.neighborhood

                //If no neighborhood name - assign it something
                if(neighborhood==""){neighborhood = "No Neighborhood"}

                //If there's no section in dictionary for this neighborhood, create new one
                if self.neighborhoods.indexForKey(neighborhood) == nil {
                    self.neighborhoods[neighborhood] = [location]
                }else {
                    self.neighborhoods[neighborhood]!.append(location)
                }
            }

            //Once all data is here - sort neighborhoods refresh table UI
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.sortedneighborhoods = self.neighborhoods.keys.sort()
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            })
        }

        //Calling the API-Manager for locations
        print("Grabbing locations")
        apiManager.fetchLocations({locations in refreshCallback(locations)})
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return neighborhoods.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return neighborhoods[sortedneighborhoods[section]]!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:LocationTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationTableViewCell!

        let tableSection = neighborhoods[sortedneighborhoods[indexPath.section]]
        let tableItem = tableSection![indexPath.row]

        cell.loadCell(tableItem)
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedneighborhoods[section]
    }

    //Call establishment if clicked on in tableview
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tableSection = neighborhoods[sortedneighborhoods[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        let alertView = SCLAlertView()
        alertView.addButton("Call them!"){
            //Get number and strip white space for handling (was going to do in location but slower if not calling very often)
            let locationNumber = tableItem.number.stringByReplacingOccurrencesOfString(" ", withString: "")
            let url:NSURL = NSURL(string: "tel://\(locationNumber)")!
            UIApplication.sharedApplication().openURL(url)
        }
        alertView.showInfo("Call \(tableItem.title)?", subTitle: "")
    }
}

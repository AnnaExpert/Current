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
    var listOfLocations = [Location]()

    override func viewDidLoad() {
        loadLocations()
    }

    //Gather array of Locations
    func loadLocations(){
        //Callback for putting received Data in the UI
        let refreshCallback: ([Location]) -> Void = { locations in

            //Checks for empty array and shows error message in case someting went wrong
            if locations.isEmpty {
                print("Returned an empty array...")
                SVProgressHUD.showErrorWithStatus("Error!")
                return
            }
            SVProgressHUD.dismiss()
            print("Successfully returned data")

            //Fill our list with returned data
            self.listOfLocations = locations

            //Once all data is here - refresh table UI
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }

        //Calling the API-Manager for locations
        print("Grabbing locations")
        SVProgressHUD.showWithStatus("Grabbing Locations")
        apiManager.fetchLocations({locations in refreshCallback(locations)})
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLocations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:LocationTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationTableViewCell!
        cell.loadCell(listOfLocations[indexPath.row])
        return cell
    }

    //Call establishment if clicked on in tableview
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertView = SCLAlertView()
        alertView.addButton("Call them!"){
            let url:NSURL = NSURL(string: "tel://\(self.listOfLocations[indexPath.row].number)")!
            UIApplication.sharedApplication().openURL(url)
        }
        alertView.showSuccess("Call \(self.listOfLocations[indexPath.row].title)?", subTitle: "")
    }
}

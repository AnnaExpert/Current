//
//  LocationsTableViewController.swift
//  Current
//
//  Created by Chase Roossin on 11/18/15.
//  Copyright © 2015 RoossinEnterprise. All rights reserved.
//

import UIKit
import SVProgressHUD
import JSQWebViewController
import DGElasticPullToRefresh

class LocationsTableViewController: UITableViewController {

    let apiManager = APIManager()
    var neighborhoods = Dictionary<String, Array<Location>>()
    var sortedneighborhoods = [String]()
    var fetchedData = false

    override func viewDidLoad() {
        //Pull to reload
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.loadLocations()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)

        //Load locations into table view
        loadLocations()
    }
    override func viewDidAppear(animated: Bool) {
        if(!fetchedData){SVProgressHUD.showWithStatus("Grabbing Locations")}
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
            self.fetchedData = true

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

    //Custom swipe functions
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let tableSection = neighborhoods[sortedneighborhoods[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        let alertView = SCLAlertView()

        //Deals with call
        let callAction = UITableViewRowAction(style: .Normal, title: "Call") { (action:
            UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            alertView.addButton("Call"){
                //Get number and strip white space for handling (was going to do in location but slower if not calling very often)
                let locationNumber = tableItem.number.stringByReplacingOccurrencesOfString(" ", withString: "")
                let url:NSURL = NSURL(string: "tel://\(locationNumber)")!
                UIApplication.sharedApplication().openURL(url)
            }
            //Remind the user that they might be closed
            var subTitle : String
            if(tableItem.isOpen()){
                subTitle = "They're open!"
            }else{subTitle = "Are you sure? They're closed."}

            alertView.showInfo("Call \(tableItem.title)?", subTitle: subTitle)
        }
        
        //Deals with visiting site
        let websiteAction = UITableViewRowAction(style: .Normal, title: "Site") { (action:
            UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let controller = WebViewController(url: NSURL(string: tableItem.website)!)
            let nav = UINavigationController(rootViewController: controller)
            self.presentViewController(nav, animated: true, completion: nil)
        }
        
        websiteAction.backgroundColor = UIColor.redColor()
        callAction.backgroundColor = UIColor.grayColor()
        return [websiteAction, callAction]
    }
}

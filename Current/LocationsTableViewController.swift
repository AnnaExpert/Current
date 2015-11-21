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
import MapKit

class LocationsTableViewController: UITableViewController {

    let apiManager = APIManager()
    var neighborhoods = Dictionary<String, Array<Location>>()
    var sortedneighborhoods = [String]()
    var fetchedData = false

    override func viewDidLoad() {
        //Dismissing search keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        //Pull to reload initialization
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
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

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        let callAction = UITableViewRowAction(style: .Normal, title: "\u{260F}\n Call") { (action:
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
        let websiteAction = UITableViewRowAction(style: .Normal, title: "\u{2605}\n Site") { (action:
            UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let controller = WebViewController(url: NSURL(string: tableItem.website)!)
            let nav = UINavigationController(rootViewController: controller)
            self.presentViewController(nav, animated: true, completion: nil)
        }

        //Deals with direction
        let directionAction = UITableViewRowAction(style: .Normal, title: "\u{21C4}\n Directions") { (action:
            UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let lat1 : NSString = tableItem.lat
            let lng1 : NSString = tableItem.lon

            let latitute:CLLocationDegrees =  lat1.doubleValue
            let longitute:CLLocationDegrees =  lng1.doubleValue

            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(tableItem.title)"
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]

            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
        
        websiteAction.backgroundColor = UIColor.alizarinColor()
        callAction.backgroundColor = UIColor.wetAsphaltColor()
        directionAction.backgroundColor = UIColor.belizeHoleColor()
        return [directionAction, callAction, websiteAction]
    }
}

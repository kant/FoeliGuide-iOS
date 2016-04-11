//
//  BusSelectionTableViewController.swift
//  FöliGuide
//
//  Created by Jonas on 19/02/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import PermissionScope

private let cellReuseIdentifier = "BusCell"
private let cellReuseIdentifierWithDistance = "BusCellWithDistance"

class BusSelectionTableViewController: UITableViewController {

	var busses = [Bus]()
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	@IBOutlet weak var locationDisabledView: UIView!
	let permissionScope = PermissionScope()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		appDelegate.applicationEventHandlers.append(self)
		appDelegate.startBusDataLoop()
		
		self.navigationItem.title = NSLocalizedString("Select your bus", comment: "Select your bus header")
		
		if appDelegate.locationController.authorized {
			tableView.tableHeaderView = nil
		}
		
		permissionScope.headerLabel.text = NSLocalizedString("Location Access", comment: "Location access header")
		permissionScope.bodyLabel.text = NSLocalizedString("Select your bus quicker and easier", comment: "Select your bus quicker and easier")
		let message = NSLocalizedString("Your location is used to locate the bus closest to you.", comment: "Your location is used to locate the bus closest to you.")
		permissionScope.addPermission(LocationWhileInUsePermission(), message: message)
    }
	
	override func viewWillDisappear(animated: Bool) {
		if self.isMovingFromParentViewController() { //View is being dismissed -> moving back to main menu
			appDelegate.stopBusDataLoop()
		}
	}

	
	override func viewDidAppear(animated: Bool) {
		loadData()
	}
	
	
	func loadData(){
		if let currentBusData = appDelegate.busController.currentBusData {
			busses = currentBusData
		}
		
			busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: appDelegate.locationController.userLocation)
		
		tableView.reloadData()
	}
	
	
	func didUpdateUserLocation(){
			busses = appDelegate.busController.sortBussesByDistanceToUser(busses: busses, userLocation: appDelegate.locationController.userLocation)
		tableView?.reloadData()
	}
	
	
	@IBAction func locationDisabledViewTapped(sender: AnyObject) {
		
		permissionScope.show({ finished, results in
			self.appDelegate.locationController.authorized = true
			self.tableView.reloadData()
			UIView.animateWithDuration(0.7, animations: {
				self.tableView.tableHeaderView = nil
			})
			
			}, cancelled: { (results) -> Void in
				self.appDelegate.locationController.authorized = false
		})
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busses.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		
		
		if appDelegate.locationController.authorized {
			let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifierWithDistance, forIndexPath: indexPath)
			
			if let busStopCell = cell as? BusSelectionTableViewCell {
				busStopCell.busNumberLabel.text = busses[indexPath.row].name
				busStopCell.finalStopLabel.text = "to \(busses[indexPath.row].finalStop)"
				
				if let distance = busses[indexPath.row].distanceToUser {
					if distance > 1000 {
						busStopCell.distanceLabel.text = String.localizedStringWithFormat(NSLocalizedString("%.2f km away", comment: "Show how far the bus is away, in km (abbreviated)"), distance / 1000)
					} else {
						busStopCell.distanceLabel.text = "\(Int(distance))" + NSLocalizedString("m away", comment: "Distance to bus, in meters (abbreviated)")
					}
				}
				
				return busStopCell
			}
			
			return cell
			
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
			
			if let busStopCell = cell as? BusSelectionTableViewCell {
				busStopCell.busNumberLabel.text = busses[indexPath.row].name
				busStopCell.finalStopLabel.text = "to \(busses[indexPath.row].finalStop)"
				return busStopCell
			}
			
			return cell
		}
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		appDelegate.busController.currentUserBus = busses[indexPath.row]
		
		
		performSegueWithIdentifier("showBusDetailViewController", sender: nil)
		appDelegate.busController.runNow()
		
		/*
		appDelegate.busController.getBusRoute(forBus: appDelegate.busController.currentUserBus!) { (busStops) -> () in
		
			
			guard busStops != nil else {
				//fall back to next/afterthat view
				self.performSegueWithIdentifier("showNextBusStopController", sender: nil)
				return
			}
			
			self.appDelegate.busController.currentUserBus?.route = busStops
			self.performSegueWithIdentifier("showBusRouteController", sender: nil)
		}
		*/
	}
	
	
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	

}


extension BusSelectionTableViewController : ApplicationEventHandler {
	func handleEvent(event: ApplicationEvent) {
		if event == .UserLocationDidUpdate {
			didUpdateUserLocation()
		}
	}
}

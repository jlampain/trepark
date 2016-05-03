//
//  TableViewController.swift
//  TrePark
//
//  Created by Jussi Lampainen on 3.10.2015.
//  Copyright © 2015 TrePark. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, ParkingHallModelDelegate {

	var model: parkHallModel!
	var didLoad: Bool = false

	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

	override func viewDidLoad() {
		super.viewDidLoad()
		model = parkHallModel(delegate: self)
		self.title = NSLocalizedString("Car parks", comment: "comment")
		loadingIndicator.hidden = false
		loadingIndicator.startAnimating()
	}

	func parkHallModelDidFinishLoading() {
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.didLoad = true
			self.loadingIndicator.hidden = false
			self.loadingIndicator.stopAnimating()
			self.tableView.reloadData()
		})

	}

	override func viewDidAppear(animated: Bool) {
		if (!didLoad) {
			loadingIndicator.startAnimating()
			loadingIndicator.hidden = false
			if (!model.beginParsing()) {

				let alertController = UIAlertController(title: "TamperePark", message:
						NSLocalizedString("Could not load parking areas.", comment: "comment"), preferredStyle: UIAlertControllerStyle.Alert)
				alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "comment"), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
					self.navigationController?.popViewControllerAnimated(true)
					}))
				self.presentViewController(alertController, animated: true, completion: nil)

			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (didLoad) {
			return NSLocalizedString("Finnpark's car parks in Tampere", comment: "comment")
		} else {
			return ""
		}
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (didLoad) {
			return model.parkingHalls.count
		} else {
			return 0;
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("ParkingCell", forIndexPath: indexPath) as! ParkingCell
		// model.parkingHalls[indexPath.row].hallName
		// Configure the cell...
		cell.title.text = model.parkingHalls[indexPath.row].hallName
		cell.status.text = model.parkingHalls[indexPath.row].hallStatus?.parkingFacilityStatus
		cell.time.text = model.parkingHalls[indexPath.row].hallStatus?.parkingFacilityStatusTime
		cell.address.text = model.parkingHalls[indexPath.row].hallAddress
		return cell
	}

	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}

}

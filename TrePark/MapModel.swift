//
//  MapModel.swift
//  TrePark
//
//  Created by Jussi Lampainen on 19.9.2015.
//  Copyright © 2015 TrePark. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import SwiftyJSON
import SwiftHTTP
import MapKit

public protocol MapModelDelegate: NSObjectProtocol {
	func mapModelDidFinishLoading()
	func mapModelError(error: String)
}

class parkingArea {

	var polygon: [CLLocationCoordinate2D] = []
	var pType: String
	var parkingDescription: String

	init(geometry: [CLLocationCoordinate2D], parkingType: String, type: String?, price: Float?, startTime: Int?, endTime: Int?, startTimeSat: Int?, endTimeSat: Int?, startTimeSun: Int?, endTimeSun: Int?, maxTime: Float?, numSlots: Int?, otherInfo: String?) {
		pType = parkingType
		polygon = geometry
		parkingDescription = "";
		if (type != nil) {

			switch (type!) {
			case "K":
				parkingDescription = NSLocalizedString("Parking disc required", comment: "comment") + "\n"
				break
			case "M":
				parkingDescription = String(format: NSLocalizedString("Paid parking", comment: "comment"), price!.description) + "\n"
				break
			case "L":
				parkingDescription = NSLocalizedString("Parking banned part of the day", comment: "comment") + "\n"
				break
			default:
				parkingDescription = NSLocalizedString("Unlimited parking", comment: "comment") + "\n"
				break
			}
		}

		if (startTime != nil && endTime != nil && startTime != 0 && endTime != 0) {
			parkingDescription = parkingDescription + NSLocalizedString("Weekdays: ", comment: "comment") + getTimeString(startTime!.description) + "-" + getTimeString(endTime!.description) + "\n"
		}

		if (startTimeSat != nil && endTimeSat != nil && startTimeSat != 0 && endTimeSat != 0) {
			parkingDescription = parkingDescription + NSLocalizedString("Saturday: ", comment: "comment") + getTimeString(startTimeSat!.description) + "-" + getTimeString(endTimeSat!.description) + "\n"
		}

		if (startTimeSun != nil && endTimeSun != nil && startTimeSun != 0 && endTimeSun != 0) {
			parkingDescription = parkingDescription + NSLocalizedString("Sunday: ", comment: "comment") + getTimeString(startTimeSun!.description) + "-" + getTimeString(endTimeSun!.description) + "\n"
		}

		if (maxTime != nil && maxTime != 0) {
			parkingDescription = parkingDescription + String(format: NSLocalizedString("Max time", comment: "comment"), maxTime!.description) + "\n"
		}

		if (numSlots != nil && numSlots != 0 && numSlots != nil) {
			parkingDescription = parkingDescription + NSLocalizedString("Parking lots", comment: "comment") + numSlots!.description
		}

		if (otherInfo != nil && type != "M" && otherInfo != "Yla §79/10.3.2009" && otherInfo != "Piir. 1/14568/4" && otherInfo != "Yla §79/10.3.2009, Piir.no 1/14549, 15.4.2008") {
			parkingDescription = parkingDescription + "\n" + NSLocalizedString("Other info", comment: "comment") + otherInfo! + "\n"
		}
	}

	func getTimeString(string: String) -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "HH"
		let date: NSDate? = dateFormatter.dateFromString(string)
		if (date != nil) {
			dateFormatter.timeStyle = .ShortStyle
			return dateFormatter.stringFromDate(date!)
		}
		return string
	}

}

class MapModel {

	var jsonData: JSON!
	var callback: MapModelDelegate

	var parkingAreas: [parkingArea] = []

	init(delegate: MapModelDelegate) {
		callback = delegate
	}

	func loadJson() {

		do {
			let opt = try HTTP.GET("http://opendata.navici.com/tampere/opendata/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opendata:KESKUSTAN_PYSAKOINTI_VIEW&outputFormat=json&srsName=EPSG:4326")
			opt.start { response in
				if let err = response.error {
					self.callback.mapModelError(err.localizedDescription)
					return
				}
				self.jsonData = JSON(data: response.data)
				if self.jsonData != JSON.null {
					self.loadParingAreas()
				} else {
					self.callback.mapModelError(NSLocalizedString("Could not load parking areas.", comment: "comment"))
				}
			}
		} catch {
			self.callback.mapModelError(NSLocalizedString("Could not load parking areas.", comment: "comment"))
		}

	}

	func loadParingAreas() {

		let data = jsonData["features"]

		for (_, subJson): (String, JSON) in data {

			// Do something you want
			var polygon: [CLLocationCoordinate2D] = []

			let geometry = subJson["geometry"]["coordinates"][0]

			for (_, item): (String, JSON) in geometry {
				// Do something you want
				let p: CLLocationCoordinate2D = CLLocationCoordinate2DMake(item[1].double!, item[0].double!)
				polygon.append(p)
			}

			let properties = subJson["properties"]

			let area: parkingArea = parkingArea(geometry: polygon, parkingType: properties["KOHDETYYPPI"].string!, type: properties["RAJOITUSTYYPPI"].string, price: properties["HINTA"].float, startTime: properties["RAJ_AIKA_ALKAA_ARK"].int, endTime: properties["RAJ_AIKA_PAATTYY_ARK"].int, startTimeSat: properties["RAJ_AIKA_ALKAA_LA"].int, endTimeSat: properties["RAJ_AIKA_PAATTYY_LA"].int, startTimeSun: properties["RAJ_AIKA_ALKAA_SU"].int, endTimeSun: properties["RAJ_AIKA_PAATTYY_SU"].int, maxTime: properties["MAX_AIKA"].float, numSlots: properties["PAIKKOJEN_LUKUMAARA"].int, otherInfo: properties["MUUTA"].string)

			parkingAreas.append(area)

		}
		callback.mapModelDidFinishLoading()
	}

}


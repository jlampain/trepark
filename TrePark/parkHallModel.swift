//
//  parkHallModel.swift
//  TrePark
//
//  Created by Jussi Lampainen on 4.10.2015.
//  Copyright © 2015 TrePark. All rights reserved.
//

import Foundation

class parkingHall {
	var hallName: String?
	var latitude: Double?
	var longitude: Double?
	var hallAddress: String?
	var hallId: String
	var hallStatus: parkingHallStatus?
	init(id: String) {
		hallId = id
	}
}

class parkingHallStatus {
	var refence: String?
	var parkingFacilityOccupancyTrend: String?
	var parkingFacilityStatus: String?
	var parkingFacilityStatusTime: String?
}

public protocol ParkingHallModelDelegate: NSObjectProtocol {
	func parkHallModelDidFinishLoading()
}

class parkHallModel: NSObject, NSXMLParserDelegate {
	
var parser = NSXMLParser()
	var parkingHalls: [parkingHall] = []
	var hall: parkingHall!
	var status: parkingHallStatus!
	var element: String = ""
	var count = 0;
	var callback: ParkingHallModelDelegate
	
	init(delegate: ParkingHallModelDelegate) {
		callback = delegate
	}
	
	func beginParsing() -> Bool {
		parkingHalls = []
		parser = NSXMLParser(contentsOfURL: (NSURL(string: "http://parkingdata.finnpark.fi:8080/Datex2/OpenData"))!)!
		parser.delegate = self
		return parser.parse()
	}
	
	func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		if (elementName == "parkingFacility") {
			hall = parkingHall(id: attributeDict["id"]!)
		}
		if (elementName == "parkingFacilityStatus") {
			if (count == 0) {
				status = parkingHallStatus()
			}
            count++
		}
		if (elementName == "parkingFacilityReference") {
			status.refence = attributeDict["id"]!
		}
		element = elementName;
	}
	
	func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
		if (elementName == "parkingFacility") {
			parkingHalls.append(hall)
		}
		if (elementName == "parkingFacilityStatus") {
			count--
			if (count == 0) {
				for (_, element) in parkingHalls.enumerate() {
					if (element.hallId == status.refence) {
						element.hallStatus = status
					}
				}
				
			}
		}
		element = "";
		
	}
	
	func parser(parser: NSXMLParser!, foundCharacters string: String!) {
		if (element == "parkingFacilityName") {
			if (hall.hallName == nil) {
				hall.hallName = string;
			} else {
				hall.hallName! += string
			}
		}
		if (element == "latitude") {
			hall.latitude = Double(string)
		}
		if (element == "longitude") {
			hall.longitude = Double(string)
		}
		
		if (element == "value") {
			if (hall.hallAddress == nil) {
				hall.hallAddress = string;
			} else {
				hall.hallAddress! += string
			}
		}
		
		if (element == "parkingFacilityOccupancyTrend") {
			status.parkingFacilityOccupancyTrend = string;
		}
		if (element == "parkingFacilityStatusTime") {
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
			let date: NSDate? = dateFormatter.dateFromString(string)
			if (date != nil) {
				dateFormatter.timeStyle = .ShortStyle
				// dateFormatter.dateStyle = .ShortStyle
				status.parkingFacilityStatusTime = dateFormatter.stringFromDate(date!)
			}
		}
		if (element == "parkingFacilityStatus" && !(string as NSString).containsString("\n")) {
			if (status.parkingFacilityStatus == nil) {
				status.parkingFacilityStatus = NSLocalizedString(string, comment: "comment")
			} else {
				status.parkingFacilityStatus = status.parkingFacilityStatus! + ", " + NSLocalizedString(string, comment: "comment")
			}
			
		}
	}
	
	func parserDidEndDocument(parser: NSXMLParser) {
		parkingHalls = parkingHalls.sort { $0.hallName < $1.hallName }
		callback.parkHallModelDidFinishLoading()
	}
	
}
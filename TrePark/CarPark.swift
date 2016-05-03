//
//  CarPark.swift
//  TrePark
//
//  Created by Jussi Lampainen on 7.10.2015.
//  Copyright © 2015 TrePark. All rights reserved.
//

import MapKit

class carPark: NSObject, MKAnnotation {
	var title: String?
	var subtitle: String?
	var latitude: Double
	var longitude: Double
	
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
	
	init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
}

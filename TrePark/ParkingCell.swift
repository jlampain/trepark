//
//  ParkingCell.swift
//  TrePark
//
//  Created by Jussi Lampainen on 5.10.2015.
//  Copyright © 2015 TrePark. All rights reserved.
//

import UIKit

class ParkingCell: UITableViewCell {
	
@IBOutlet weak var title: UILabel!
	@IBOutlet weak var status: UILabel!
	@IBOutlet weak var time: UILabel!
	@IBOutlet weak var address: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		time.frame = CGRectMake(UIScreen.mainScreen().bounds.width - time.frame.width - 10, time.frame.origin.y, time.frame.width, status.frame.height)
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}

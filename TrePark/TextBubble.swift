//
//  TextBubble.swift
//  TrePark
//
//  Created by Jussi Lampainen on 22.9.2015.
//  Copyright © 2015 TrePark. All rights reserved.
//

import UIKit

class TextBubble: UITextView {

	override func drawRect(rect: CGRect) {

		let bubbleSpace = CGRectMake(1, self.bounds.origin.y + 1, self.bounds.width - 2, self.bounds.height - 10)
		let trianglePath = UIBezierPath()
		trianglePath.lineWidth = 1.0
		let startPoint = CGPoint(x: self.bounds.width / 2 - 20, y: self.bounds.height - 30)
		let tipPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.height - 3)
		let endPoint = CGPoint(x: self.bounds.width / 2 + 20, y: self.bounds.height - 30)
		trianglePath.moveToPoint(startPoint)
		trianglePath.addLineToPoint(tipPoint)
		trianglePath.addLineToPoint(endPoint)
		trianglePath.closePath()
		UIColor.whiteColor().setFill()
		UIColor.lightGrayColor().setStroke()

		trianglePath.stroke()

		let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 5)
		bubblePath.lineWidth = 1.0
		UIColor.whiteColor().setFill()
		UIColor.lightGrayColor().setStroke()
		bubblePath.stroke()
		bubblePath.fill()
		trianglePath.fill()
	}
}


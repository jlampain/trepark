//
//  MapMarker.swift
//  TrePark
//
//  Created by Jussi Lampainen on 15.9.2015.
//  Copyright (c) 2015 TrePark. All rights reserved.
//

import UIKit
import CoreGraphics

class MapMarker: UIView {
    
    var carIcon:UIImage = UIImage(named: "car.png")!

    override func drawRect(rect: CGRect) {
        
        var bubbleSpace = CGRectMake(10, self.bounds.origin.y + 10, self.bounds.width - 20, self.bounds.height - 20)
        let trianglePath = UIBezierPath()
        trianglePath.lineWidth = 3.0
        let startPoint = CGPoint(x: self.bounds.width / 2 - 20, y: self.bounds.height - 30)
        let tipPoint = CGPoint(x: self.bounds.width / 2,  y: self.bounds.height-3)
        let endPoint = CGPoint(x: self.bounds.width / 2 + 20 , y: self.bounds.height - 30)
        trianglePath.moveToPoint(startPoint)
        trianglePath.addLineToPoint(tipPoint)
        trianglePath.addLineToPoint(endPoint)
        trianglePath.closePath()
		UIColor(red: 39 / 255, green: 174 / 255, blue: 96 / 255, alpha: 1).setStroke()
        UIColor(red: 49/255, green: 204/255, blue: 113/255, alpha: 1).setFill()
        trianglePath.stroke()
        
        let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: (self.bounds.height - 20) / 2)
        bubblePath.lineWidth = 3.0
        UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1).setStroke()
        UIColor(red: 49/255, green: 204/255, blue: 113/255, alpha: 1).setFill()
        bubblePath.stroke()
        bubblePath.fill()
        trianglePath.fill()
        
        bubbleSpace = CGRectMake(15, self.bounds.origin.y + 15, self.bounds.width - 30, self.bounds.height - 30)
        carIcon.drawInRect(bubbleSpace)
        
    }
    

}

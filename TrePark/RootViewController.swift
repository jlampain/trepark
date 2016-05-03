//
//  RootViewController.swift
//  TrePark
//
//  Created by Jussi Lampainen on 13.9.2015.
//  Copyright (c) 2015 TrePark. All rights reserved.
//

import UIKit
import MapKit
import KCSelectionDialog

class RootViewController: UIViewController, MKMapViewDelegate,MapModelDelegate,ParkingHallModelDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var location:CLLocationCoordinate2D!
    var mapModel:MapModel!
    var carParkModel: parkHallModel!
    var onTarget:Bool = false;
    var switchButton: UIBarButtonItem!
    var tampereButton: UIBarButtonItem!
    var layersButton: UIBarButtonItem!
    var filter = ""
    
    let layers = [NSLocalizedString("Parking areas", comment: "comment"),NSLocalizedString("Parking areas", comment: "comment"),NSLocalizedString("Parking areas", comment: "comment")]
    
    @IBAction func layersButtonPressed(sender: AnyObject) {
        
        let dialog = KCSelectionDialog(title: NSLocalizedString("Show in map", comment: "comment"), closeButtonTitle: NSLocalizedString("Dismiss", comment: "comment"))
        
        dialog.addItem(item: NSLocalizedString("All parking areas", comment: "comment"),didTapHandler: { () in
            self.filter = "";
            self.title = NSLocalizedString("Parking areas", comment: "comment")

            self.areas = []
            dialog.close()
            self.mapView.addOverlays(self.parkAreas)
            
            self.mapView.centerCoordinate = self.nearestParkingArea()!.overlay.coordinate

            
            // just show the text box if needed
            var newPos:CLLocationCoordinate2D = self.mapView.centerCoordinate
            newPos.latitude += 0.00001
            self.mapView.setCenterCoordinate(newPos, animated: true)
        })
        
        dialog.addItem(item: NSLocalizedString("Motorbike parking areas", comment: "comment"),didTapHandler: { () in
            self.filter = "M";
            self.title = NSLocalizedString("Motorbike parking areas", comment: "comment")
            self.areas = []
            dialog.close()
            self.mapView.addOverlays(self.parkAreas)
            self.mapView.centerCoordinate = self.nearestParkingArea()!.overlay.coordinate
            // just show the text box if needed
            var newPos:CLLocationCoordinate2D = self.mapView.centerCoordinate
            newPos.latitude += 0.00001
            self.mapView.setCenterCoordinate(newPos, animated: true)
        })
        
        dialog.addItem(item: NSLocalizedString("Invalid parking areas", comment: "comment"),didTapHandler: { () in
            self.filter = "I";
            self.title = NSLocalizedString("Invalid parking areas", comment: "comment")
            self.areas = []
            dialog.close()
            self.mapView.addOverlays(self.parkAreas)
            self.mapView.centerCoordinate = self.nearestParkingArea()!.overlay.coordinate

            // just show the text box if needed
            var newPos:CLLocationCoordinate2D = self.mapView.centerCoordinate
            newPos.latitude += 0.00001
            self.mapView.setCenterCoordinate(newPos, animated: true)
        })

        dialog.show()

    }
    
    func nearestParkingArea() -> MKPolygonRenderer?{
        
        var minDistance: Double = 100000;
        var closestArea: MKPolygonRenderer?
        
        for item in areas {
            let distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(mapView.centerCoordinate), MKMapPointForCoordinate(item.overlay.coordinate))
            if (distance < minDistance) {
                minDistance = distance
                closestArea = item
            }
        }
        
        return closestArea
        
    }

    
    @IBOutlet weak var locationButton: UIBarButtonItem!
    var selectedAread: MKPolygonRenderer?
    
    
    @IBOutlet weak var carParkButton: UIButton!
    var areas: [MKPolygonRenderer] = [];
    var carParks: [MKAnnotation] = [];
    var parkAreas: [MKPolygon] = [];
    
    @IBAction func userLocation(sender: AnyObject) {
        self.mapView.centerCoordinate = location
    }
    @IBOutlet weak var carShadow: UIView!
    @IBOutlet weak var carMarker: MapMarker!
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBAction func barButtonItemClicked(sender: UIBarButtonItem) {
        let newCamera:MKMapCamera = mapView.camera
        newCamera.pitch = 40.0
        newCamera.altitude = 1500.0
        mapView.setCamera(newCamera, animated: false)
        self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 61.4991994798452, longitude: 23.7600351999292), animated: false)
     }
    
    @IBAction func barButtonItemClicked2(sender: UIBarButtonItem) {
        hideParkingAreas(!self.carMarker.hidden)
    }
    
    
    func hideParkingAreas(hide: Bool){
        self.carMarker.hidden = hide
        self.carShadow.hidden = hide
        if (hide){
            areas = []
            self.filter = "";
            self.layersButton.enabled = false
            self.title = NSLocalizedString("Car parks", comment: "comment")
            self.mapView.removeOverlays(parkAreas)
            self.mapView.addAnnotations(carParks)
            self.textView.hidden = hide
            selectedAread = nil
            let systemButton = UIBarButtonItem(title: NSLocalizedString("Parking areas", comment: "comment"), style: .Plain, target: self, action: "barButtonItemClicked2:")
            var items = toolbar.items!
            items[0] = systemButton
            toolbar.setItems(items, animated: true)
        } else {
            self.title = NSLocalizedString("Parking areas", comment: "comment")
            self.layersButton.enabled = true
            self.mapView.addOverlays(parkAreas)
            self.mapView.removeAnnotations(carParks)
            selectedAread = nil
            let systemButton = UIBarButtonItem(title: NSLocalizedString("Car parks", comment: "comment"), style: .Plain, target: self, action: "barButtonItemClicked2:")
            var items = toolbar.items!
            items[0] = systemButton
            toolbar.setItems(items, animated: true)
            
            // just show the text box if needed
            var newPos:CLLocationCoordinate2D = self.mapView.centerCoordinate
            newPos.latitude += 0.00001
            self.mapView.setCenterCoordinate(newPos, animated: true)
            
            
        }
    }
    
    func mapModelError(error: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        let alertController = UIAlertController(title: "TamperePark", message:
            error, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: "comment"), style: UIAlertActionStyle.Default,handler: { (action: UIAlertAction!) in
                self.mapModel.loadJson()
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    
    func mapModelDidFinishLoading(){
        dispatch_async(dispatch_get_main_queue(), {
            for item in self.mapModel.parkingAreas {
                let p: MKPolygon  = MKPolygon(coordinates: &item.polygon, count: item.polygon.count)
                p.title = item.parkingDescription
                p.subtitle = item.pType
                self.parkAreas.append(p)
                self.mapView.addOverlay(p)
            }
            self.title = NSLocalizedString("Parking areas", comment: "comment")
            self.waitIndicator.stopAnimating()
            self.waitIndicator.hidden = true
            self.mapView.hidden = false
            self.carMarker.hidden = false
            self.carShadow.hidden = false
            self.tampereButton.enabled = true
            self.switchButton.enabled = true
            self.carParkButton.enabled = true
            self.locationButton.enabled = true
            self.layersButton.enabled = true
            
            self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 61.4991994798452, longitude: 23.7600351999292), animated: true)

        })
    }
    
    func parkHallModelDidFinishLoading() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.mapView.removeAnnotations(self.carParks)
            for item in self.carParkModel.parkingHalls {
                if (item.latitude != nil && item.longitude != nil){
                let annotation = carPark(latitude: item.latitude!, longitude: item.longitude!)
                annotation.title = item.hallName
                annotation.subtitle = item.hallStatus?.parkingFacilityStatus
                self.carParks.append(annotation)
                    if (self.carMarker.hidden && self.tampereButton.enabled){
                        self.mapView.addAnnotations(self.carParks)
                    }
                }
            }
        
        
        })
        
    }

     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationButton.enabled = false
        
        waitIndicator.startAnimating()
        waitIndicator.center =  CGPointMake(mapView.center.x, mapView.center.y - 80)
        carParkButton.enabled = false
        
        textView.hidden = true
        textView.scrollEnabled = false
        //textView.center = CGPointMake(mapView.center.x, mapView.center.y - 145)
        mapView.hidden = true;
        mapView.pitchEnabled = false;
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        carMarker.hidden = true
        carShadow.hidden = true
        carMarker.center = CGPointMake(mapView.center.x, mapView.center.y - 64)
        
        carShadow.center = CGPointMake(mapView.center.x, mapView.center.y - 32)
        carShadow.layer.cornerRadius = carShadow.frame.width / 2
        
        var toolBarItems = [UIBarButtonItem]()
        
        switchButton = UIBarButtonItem(title: NSLocalizedString("Car parks", comment: "comment"), style: .Plain, target: self, action: "barButtonItemClicked2:")
        toolBarItems.append(switchButton)
        switchButton.enabled = false
        
        let systemButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBarItems.append(systemButton2)
        
        layersButton = UIBarButtonItem(image: UIImage(named: "ic_layers_white"), style: .Plain, target: self, action: "layersButtonPressed:")
        
        toolBarItems.append(layersButton)
        self.layersButton.enabled = false
        
        toolBarItems.append(systemButton2)


        
        tampereButton = UIBarButtonItem(title: NSLocalizedString("Tampere", comment: "comment"), style: .Plain, target: self, action: "barButtonItemClicked:")
        
        tampereButton.enabled = false
        toolBarItems.append(tampereButton)

        toolbar.items = toolBarItems;
        
       
        let span = MKCoordinateSpanMake(0.1,0.1)
        
        location = CLLocationCoordinate2D(
            latitude: 61.4991994798452, longitude: 23.7600351999292
        )
        
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    
        let newCamera:MKMapCamera = mapView.camera
        newCamera.pitch = 40.0
        newCamera.altitude = 1500.0
        mapView.setCamera(newCamera, animated: false)
       // mapView.setCenterCoordinate(location, animated: true)
        
        mapModel = MapModel(delegate: self)
        self.mapModel.loadJson();
        
        carParkModel = parkHallModel(delegate:self)

    }
    
    override func viewDidAppear(animated: Bool) {
        carParkModel.beginParsing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolygon {
            
            if (filter == overlay.subtitle! || filter == "") {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.lineWidth = 1;
            polygonView.fillColor = UIColor.clearColor()
            polygonView.strokeColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)
            areas.append(polygonView);
            return polygonView
            }
            
        }
        return nil
    }
    
    func moveImage(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = false
        animation.duration = 0.3
        animation.autoreverses = false
        animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x, view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x, view.center.y - 25))
        view.layer.addAnimation(animation, forKey: "positionup")
    }
    
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        if (!carMarker.hidden){
            if (selectedAread != nil) {
                selectedAread!.fillColor = UIColor.clearColor()
                selectedAread!.strokeColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)
            }
            moveImage(carMarker);
            textView.hidden = true
        }
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        if (!carMarker.hidden){
            panningStopped()
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation
        userLocation: MKUserLocation) {
        location = userLocation.location?.coordinate
    }
    
    func panningStopped() {
        carMarker.layer.removeAnimationForKey("positionup")
        let animation = CABasicAnimation(keyPath: "position")
        var newArea: MKPolygonRenderer?
        newArea = insideParkingArea()
        if (newArea != selectedAread && newArea != nil){
            selectedAread = newArea
            mapView.centerCoordinate = newArea!.overlay.coordinate
        } else {
            selectedAread = newArea
        }
        animation.fillMode = kCAFillModeBackwards;
        animation.removedOnCompletion = true
        animation.duration = 0.3
        animation.autoreverses = false
        animation.fromValue = NSValue(CGPoint: CGPointMake(carMarker.center.x, carMarker.center.y - 25))
        animation.toValue = NSValue(CGPoint: CGPointMake(carMarker.center.x, carMarker.center.y))
        animation.delegate = self
        carMarker.layer.addAnimation(animation, forKey: "positiondown")
    }
    
    func insideParkingArea() -> MKPolygonRenderer?{
        
        let rect: CGRect = carShadow.layer.bounds
        let p: CLLocationCoordinate2D = mapView.convertPoint(CGPointMake(rect.midX,rect.midY),toCoordinateFromView: carShadow)

        for item in areas {
            if (CGPathContainsPoint(item.path, nil, item.pointForMapPoint(MKMapPointForCoordinate(p)),false)){
                return item;
            }
        }
        
        
        
        var minDistance: Double = 100000;
        var closestArea: MKPolygonRenderer?
        
        for item in areas {
            let distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(mapView.centerCoordinate), MKMapPointForCoordinate(item.overlay.coordinate))
            if (distance < minDistance) {
                minDistance = distance
                closestArea = item
            }
        }
        
        if (minDistance < 40){
        return closestArea
        }
        
        return nil
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if (selectedAread != nil){
        selectedAread!.fillColor = UIColor.orangeColor()
        selectedAread!.strokeColor = UIColor.orangeColor()
        
        textView.text = selectedAread!.overlay.title!
        let contentSize = textView.sizeThatFits(CGSize(width: 200, height: 1000))
        var frame = textView.frame
        frame.size.height = contentSize.height
        frame.size.width = 240

        frame.origin = CGPointMake(mapView.center.x - 120, mapView.center.y - contentSize.height - 75)
        textView.frame = frame
        textView.hidden = false
        }
        
    
    }
    
    /*
    // MARK: - Navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
   
}

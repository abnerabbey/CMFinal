//
//  MapViewController.swift
//  FinalCM
//
//  Created by Antonio Santiago on 10/27/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: ATTRIBUTES
    
    var mapParser = MapXMLParser()
    var pointAnnotation = MKPointAnnotation()
    var MKPin = MKPinAnnotationView()
    
    var mkAnnotationStores: [Store] = []
    
    var displayIndex = 0
    
    var storesInfo = [[String: String]]()
    var distancesToStores = [CLLocationDistance]()
    var storesLocation = [CLLocationCoordinate2D]()
    var userLocation = CLLocationCoordinate2D()
    
    var startCalculations = false
    
    // MARK: OUTLETS
    
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeDistance: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoLabelView: UILabel!
    @IBOutlet weak var closeInfoViewButton: UIButton!
    @IBOutlet weak var showInfoViewButton: UIButton!
    @IBOutlet weak var infoNameLabel: UILabel!
    @IBOutlet weak var infoDistanceLabel: UILabel!
    @IBOutlet weak var infoTimeLabel: UILabel!
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    // MARK: CLLocationManager Attributes
    var locationManager: CLLocationManager!

    // MARK: ACTIONS
    @IBAction func getDirectionsButtonPressed(sender: UIButton) {
        if(startCalculations) {
            getDirections()
        }
    }
    
    @IBAction func navigateList(sender: UIButton) {
        if sender.tag == 0 {        // LEFT
            if displayIndex == 0 {
                displayIndex = storesInfo.count-1
            } else {
                displayIndex--
            }
        } else {                    // RIGHT
            if displayIndex == storesInfo.count-1 {
                displayIndex = 0
            } else {
                displayIndex++
            }
        }
        displayStoreInLabel(displayIndex)
        mkMapView.selectAnnotation(findAnnotation(displayIndex), animated: true)
    }
    
    @IBAction func closeInfoViewButtonTapped(sender: UIButton) {
        infoView.hidden = true
        showInfoViewButton.hidden = false
    }
    
    @IBAction func showInfoViewButtonTapped(sender: UIButton) {
        infoView.hidden = false
        showInfoViewButton.hidden = true
    }
    
    // MARK: METHODS
    
    func startLocationServices() {

        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
        }
    }
    
    func calculateDistances() {     // Calculate the distance between the userLocation and the location of each store. RETURNS ARRAY TO USE AS LIST
        var counter = 0
        var currentStoreLocation: CLLocation
        var element = [String:String]()
        
        /*
        Description of this for cycle
        1. Store Latitude and Longitude from storesInfo in temporal variables
        2. Use latitude and longitude to conform CLLocation
        3. Calculate distance between user location and store location
        4. Append this distance to distanceToStores (this step could be deleted if no longer used)
        5. Add this distance as a new key for the storesInfo Dictionary
        */
        for stores in storesInfo {
            print("About to read data from \(stores)")
            let currentLat = Double(stores["LATITUDE"]!)
            let currentLon = Double(stores["LONGITUDE"]!)
            currentStoreLocation = CLLocation(latitude: currentLat!, longitude: currentLon!)
            print("User location is:\nLatitude: \(userLocation.latitude)\nLongitude: \(userLocation.longitude)")
            let distanceToStore = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude).distanceFromLocation(currentStoreLocation)
            distancesToStores.append(distanceToStore)
            element["DISTTOUSER"] = String(distanceToStore)
            
            storesInfo[counter]["DISTTOUSER"] = String(distanceToStore)
            print("Current state of stores is:\n \(stores)")

            // storesInfo.append(element)
            print("Distance to store number \(counter) is \(distancesToStores[counter])")
            counter++
        }
        
        print("Final value of storesInfo BEFORE SORTING is:\n")
        for stores in storesInfo {
            print(stores)
        }
        
        // Sorting storesInfo according to distance from store to user location (bubble sort)
        
        var swaps = true
        while (swaps) {
            swaps = false
            for var i=0; i<storesInfo.count; i++ {
                if !(i+1 == storesInfo.count) {                                             // Making sure Dictionary index is valid
                    print("Will work with index \(i)")
                    let currentValue: Double =  Double(storesInfo[i]["DISTTOUSER"]!)!
                    let nextValue: Double = Double(storesInfo[i+1]["DISTTOUSER"]!)!
                    
                    if(currentValue > nextValue) {                                          // If the next value is smaller...
                        let auxVar = storesInfo[i]
                        storesInfo[i] = storesInfo[i+1]                                     // Current value will now be the next value
                        storesInfo[i+1] = auxVar
                        swaps = true
                    }
                }
            }
        }
        
        print("Final value of storesInfo AFTER SORTING is:\n")
        for stores in storesInfo {
            print(stores)
        }
        
        print("Final value of mkAnnotationStores is:\n")
        for stores in mkAnnotationStores {
            print(stores.name)
            print(stores.location)
        }
    }
    
    func displayStoreInLabel(index: Int) {
        
        // Display stores in View (labels)
        storeName.text = "\(index+1). \(storesInfo[index]["NAME"]!)"
        storeDistance.text = "A \(storesInfo[index]["DISTTOUSER"]!) metros"
    }
    
    func findAnnotation(index: Int) -> MKAnnotation{
        let name = storesInfo[index]["NAME"]
        var aux:Int = 0
        var annotationIndex:Int = 0
        for mkStore in mkAnnotationStores {
            if mkStore.name == name {
                annotationIndex = aux
            }
            aux++
        }
        return mkAnnotationStores[annotationIndex]
    }
    
    /*
    HARDCODED METHOD. When user selects a Pin in mapView, this method searches for the Store Title and if it is found, changes the text label in the lower view.
    Ideal solution to this would be to add a field in Store (such as an Int index) and use displayStoreInLabel with that index. This doesn't work because up till now, no way to increment the auxCounter has been found, at the moment when the MKPinAnnotationView are created
    */
    func changeLabelFromPinSelected(name: String) {
        
        var aux = 0
        for stores in storesInfo {
            if name == stores["NAME"] {
                displayStoreInLabel(aux)
            }
            aux++
        }
    }
    
    func getDirections() {
        let auxLat = CLLocationDegrees(storesInfo[displayIndex]["LATITUDE"]!)!
        let auxLon = CLLocationDegrees(storesInfo[displayIndex]["LONGITUDE"]!)!
        let destCoordinate = CLLocationCoordinate2D(latitude: auxLat, longitude: auxLon)
        let destinationPlace = MKPlacemark(coordinate: destCoordinate, addressDictionary: nil)
        let destination = MKMapItem(placemark: destinationPlace)
        
        let currentPosition = MKMapItem.mapItemForCurrentLocation()
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.destination = destination
        directionRequest.source = currentPosition
        directionRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: directionRequest)
        directions.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse?, error: NSError?) -> Void in
            
            // Additional info labels for Route
            
            // Advisory Notices
            
            self.infoLabelView.text = "Avisos: Ninguno"
            if let notices = response!.routes.first?.advisoryNotices {
                self.infoLabelView.textColor = UIColor.blackColor()
                self.infoLabelView.font = UIFont.systemFontOfSize(12)
                for notice in notices {
                    if notice == "This route requires tolls." {
                        self.infoLabelView.textColor = UIColor.redColor()
                        self.infoLabelView.font = UIFont.boldSystemFontOfSize(12)
                        self.infoLabelView.text = "Avisos: Ruta con cuota"
                    } else if notice == "This route ends on the road nearest to the selected destination." {
                        self.infoLabelView.text = "Avisos: Final de la ruta sin pavimento"
                    } else if notice == "" {
                        self.infoLabelView.text = "Avisos: Ninguno"
                    } else {
                        self.infoLabelView.text = "Avisos: Ninguno"
                    }
                }
            } else {
                self.infoLabelView.text = "Avisos: Ninguno"
            }
            
            // Route Name
            
            if let name = response!.routes.first?.name {
                self.infoNameLabel.text = "Avenida principal: \(name)"
            } else {
                self.infoNameLabel.text = "Avenida principal no disponible :("
            }
            
            // Route Distance
            
            if let distance = response!.routes.first?.distance {
                self.infoDistanceLabel.text = "Distancia total: \(distance) m"
            } else {
                self.infoDistanceLabel.text = "Distancia no disponible :("
            }
            
            // Route ETA
            
            if let time = response!.routes.first?.expectedTravelTime {
                if time >= 3600 {
                    let seconds = time%60
                    let minutes = ((time-seconds)%3600)/60
                    let hours = (time-(time%3600))/3600
                    self.infoTimeLabel.text = "A \(Int(hours))h \(Int(minutes))m \(Int(seconds))s"
                } else if time>60 {
                    let seconds = time%60
                    let minutes = (time-(seconds))/60
                    self.infoTimeLabel.text = "A \(Int(minutes))m \(Int(seconds))s"
                } else {
                    self.infoTimeLabel.text = "A \(time)s"
                }
            } else {
                self.infoTimeLabel.text = "Tiempo de ruta no disponible :("
            }

            if self.mkMapView.overlays.count != 0 {
                self.mkMapView.removeOverlays(self.mkMapView.overlays)
            }
            self.mkMapView.addOverlay((response?.routes.first?.polyline as? MKOverlay)!)
        }
        infoView.hidden = false
        showInfoViewButton.hidden = true
    }
    
    override func viewDidLoad() {
        
        startLocationServices()
        if mapParser.verifyValues() {
            startCalculations = true
            var auxCounter = 0
            for stores in mapParser.posts {
                storesInfo.append(stores)
                let auxTitle: String = stores["NAME"]!
                let auxLatitude: Double = Double(stores["LATITUDE"]!)!
                let auxLongitude: Double = Double(stores["LONGITUDE"]!)!
                mkAnnotationStores.append(Store(name: auxTitle, latitude: auxLatitude, longitude: auxLongitude, index: auxCounter))
                auxCounter++
            }
            
            self.mkMapView.delegate = self
            self.mkMapView.addAnnotations(self.mkAnnotationStores)
            
            let rectToDisplay = self.mkAnnotationStores.reduce(MKMapRectNull) {     // Rectangle area where the view will load
                (mapRect: MKMapRect, mkAnnotationStore: Store) -> MKMapRect in
                let storePointRect = MKMapRect(origin: MKMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(mkAnnotationStore.location.latitude), CLLocationDegrees(mkAnnotationStore.location.longitude))), size: MKMapSize(width: 0, height: 0))
                return MKMapRectUnion(mapRect, storePointRect)
            }
            
            self.mkMapView.setVisibleMapRect(rectToDisplay, edgePadding: UIEdgeInsetsMake(CGFloat(200), CGFloat(200), CGFloat(200), CGFloat(200)), animated: false)
            
        } else {
            let noConnectionController = UIAlertController(title: "Conexión no establecida", message: "El servidor no está disponible o no tienes acceso a Internet. Intenta más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
            noConnectionController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction: UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(noConnectionController, animated: true, completion: nil)
        }
            
        super.viewDidLoad()
        
        self.navigationItem.title = "Ubica tu Tienda"
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MKMapViewDelegate Methods
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        changeLabelFromPinSelected((view.annotation?.title!)!)
        view.highlighted = true
        view.setSelected(true, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if let store = annotation as? Store {
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as! MKPinAnnotationView!
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                view.canShowCallout = true
                view.pinTintColor = UIColor.purpleColor()
                view.animatesDrop = true
                view.calloutOffset = CGPoint(x: -5, y: -5)
                // view.image = UIImage(named: "pin2")
            } else {
                view.annotation = annotation
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKPolyline){
            let route = overlay as! MKPolyline
            let polyline = MKPolylineRenderer(polyline: route)
            polyline.lineWidth = 5.0
            polyline.strokeColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
            return polyline
        }
        else{
            return MKPolylineRenderer()
        }
    }
    
    // CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locationManager.location!.coordinate
        print("locations = \(userLocation.latitude) \(userLocation.longitude)")
        
        if(startCalculations) {
            calculateDistances()
            displayStoreInLabel(displayIndex)
        }
    }
}
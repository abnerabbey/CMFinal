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
    
    override func viewDidLoad() {
        
        startLocationServices()
        if mapParser.verifyValues() {
            startCalculations = true
            print("Copiando valores desde XMLParser")
            mapParser.posts.append(["NAME": "Bodega Aurrera", "LONGITUDE": "-100.158607", "LATITUDE": "19.335284"])
            mapParser.posts.append(["NAME": "Superama", "LONGITUDE": "-98.158609", "LATITUDE": "19.235281"])
            mapParser.posts.append(["NAME": "OXXO Cuajimalpa", "LONGITUDE": "-98.158611", "LATITUDE": "19.335282"])
            mapParser.posts.append(["NAME": "Seven Eleven", "LONGITUDE": "-98.158600", "LATITUDE": "19.335287"])
            mapParser.posts.append(["NAME": "Comercial Mexicana", "LONGITUDE": "-98.158601", "LATITUDE": "19.335288"])
            var auxCounter = 0
            for stores in mapParser.posts {
                storesInfo.append(stores)
                let auxTitle: String = stores["NAME"]!
                let auxLatitude: Double = Double(stores["LATITUDE"]!)!
                let auxLongitude: Double = Double(stores["LONGITUDE"]!)!
                mkAnnotationStores.append(Store(name: auxTitle, latitude: auxLatitude, longitude: auxLongitude, index: auxCounter))
                auxCounter++
                
                // Aquí voy a obtener las direcciones desde el usuario hasta las stores :)
                // self.getDirections(auxLatitude, longitud: auxLongitude)
            }
            /*
            mkAnnotationStores.append(Store(name: "Tú", latitude: userLocation.latitude, longitude: userLocation.longitude))
            */
            
            self.mkMapView.delegate = self
            self.mkMapView.addAnnotations(self.mkAnnotationStores)
            
            let rectToDisplay = self.mkAnnotationStores.reduce(MKMapRectNull) {     // Rectangle area where the view will load
                (mapRect: MKMapRect, mkAnnotationStore: Store) -> MKMapRect in
                let storePointRect = MKMapRect(origin: MKMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(mkAnnotationStore.location.latitude), CLLocationDegrees(mkAnnotationStore.location.longitude))), size: MKMapSize(width: 0, height: 0))
                return MKMapRectUnion(mapRect, storePointRect)
            }
            
            self.mkMapView.setVisibleMapRect(rectToDisplay, edgePadding: UIEdgeInsetsMake(CGFloat(200), CGFloat(200), CGFloat(200), CGFloat(200)), animated: false)
            // calculateDistances()
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
            polyline.strokeColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
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
            if self.mkMapView.overlays.count != 0 {
                self.mkMapView.removeOverlays(self.mkMapView.overlays)
            }
            self.mkMapView.addOverlay((response?.routes.first?.polyline as? MKOverlay)!)
        }
    }
}




































































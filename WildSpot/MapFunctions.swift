//
//  MapFunctions.swift
//  WildSpot
//
//  Created by John Fandrey on 8/25/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapFunctions: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var location = CLLocationCoordinate2D()
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        zoomLevelSlider.value = Float(1/mapView.region.span.latitudeDelta)
    }
    
    var locationManager = CLLocationManager()
    
    class func sharedInstance() -> MapViewController {  // Declare a function that creates an instance of MapViewController.  This function returns an instance of MapViewController, thus the other objects can access the functions in MapViewController through this function.
        struct Singleton {
            static var sharedInstance = MapViewController()
        }
        return Singleton.sharedInstance
    }
    
    func configureMapView(){
        mapView.showsUserLocation = true
    }
    
    func getLocation(){
        // code for getting the user location was obtained from a StackOverflow post by PMIW dated August 22, 2014 at https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift#.
        if (CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            var coordinateRegion: MKCoordinateRegion!
            let location = locationManager.location
            let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            if let coordinate = location?.coordinate {
                coordinateRegion = MKCoordinateRegionMake(coordinate, span)
                mapView.setRegion(coordinateRegion, animated: true)
            } else {
                centerMapOnLocation(nil, nil)
            }
        } else {
            centerMapOnLocation(nil, nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let userLocation = locations.last
        let viewRegion = MKCoordinateRegionMakeWithDistance((userLocation?.coordinate)!, 600, 600)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D?, _ span: Float?) {
        // I found the code for setting the initial map location as seen below at https://www.raywenderlich.com/160517/mapkit-tutorial-getting-started.  The original post was by Ray Wenderlich and was updated by Audrey Tam on June 27, 2017.
        // This function sets a coordinateRegion and sets Region for the mapView.
        var coordinateRegion: MKCoordinateRegion!
        if location != nil && span != nil {
            let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(span!), longitudeDelta: CLLocationDegrees(span!))
            coordinateRegion = MKCoordinateRegionMake(location!, span)
            mapView.setRegion(coordinateRegion, animated: true)
        } else {
            let defaultLocation = CLLocationCoordinate2D(latitude: 40, longitude: -40)
            let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(10), longitudeDelta: CLLocationDegrees(10))
            coordinateRegion = MKCoordinateRegionMake(defaultLocation, span)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
}

//
//  Location Services.swift
//  WildSpot
//
//  Created by John Fandrey on 9/14/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension MapViewController {
    
    // centerMapOnLocation centers the map and sets the visible span.   
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D?, _ span: MKCoordinateSpan?) {
        // I found the code for setting the initial map location as seen below at https://www.raywenderlich.com/160517/mapkit-tutorial-getting-started.  The original post was by Ray Wenderlich and was updated by Audrey Tam on June 27, 2017.
        // This function sets a coordinateRegion and sets Region for the mapView.
        if location != nil && span != nil {
        var coordinateRegion = MKCoordinateRegionMake(location!, span!)
            mapView.setRegion(coordinateRegion, animated: true)
        } else {
            let defaultLocation = CLLocationCoordinate2D(latitude: 35, longitude: -100)
            let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(45), longitudeDelta: CLLocationDegrees(45))
            let coordinateRegion = MKCoordinateRegionMake(defaultLocation, span)
           mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    
}

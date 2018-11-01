//
//  MapViewDelegate.swift
//  WildSpot
//
//  Created by John Fandrey on 9/14/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import UIKit

extension MapViewController {
    
    // This delegate method returns an MKAnnotation view.  The method also determines the color of the pin.  Pins from Flickr are blue.  Pins from Firebase and CoreData are green.
    
    func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // I used the PinSample App and the Ray Wenderlich tutorial updated by Audrey Tam to get the delegate function below to work properly.  I was having issues with getting pins to be displayed instead of balloons or markers.
        let identifier = "marker"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
            let subtitle: String = (view.annotation?.subtitle!)!
            if subtitle.contains("flickr") || subtitle.starts(with: "http") || subtitle.contains("random string"){
                view.pinTintColor = UIColor.blue
                return view
            } else {
                    view.pinTintColor = UIColor.green
                    return view
            }
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let subtitle: String = (view.annotation?.subtitle!)!
            if subtitle.contains("flickr") || subtitle.starts(with: "http") || subtitle.contains("random string"){
                view.pinTintColor = UIColor.blue
                return view
            } else {
                view.pinTintColor = UIColor.green
                return view
                }
            }
            return view
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let span: MKCoordinateSpan = mapView.region.span
        if span.latitudeDelta < 90 && span.longitudeDelta < 90 {
            zoomOut.isEnabled = true
        } else {
            zoomOut.isEnabled = false
        }
        if span.longitudeDelta < 0.1 && span.latitudeDelta < 0.1 {
            zoomIn.isEnabled = false
        }else{
            zoomIn.isEnabled = true
        }
    }
    
     // This delegate method is called when a pin is tapped.  The method calls pinTap.
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        pinTap(view: view)
    }
    
    // getBoundingBox is used to establish the four bounds of the search box sent to flickr.
    
    func getBoundingBox() -> [String:String]{
        let mapRectangle: MKCoordinateRegion = self.mapView.region
        let mapSpan: MKCoordinateSpan = mapRectangle.span
        var minLongitude = Double()
        var maxLatitude = Double()
        var maxLongitude = Double()
        var minLatitude = Double()
        var boundingBox = ["minLongitude":"", "minLatitude":"", "maxLongitude":"", "maxLatitude":""]
        
        minLongitude = mapRectangle.center.longitude - (mapSpan.longitudeDelta / 2)
        maxLongitude = mapRectangle.center.longitude + (mapSpan.longitudeDelta / 2)
        minLatitude = mapRectangle.center.latitude - (mapSpan.latitudeDelta / 2)
        maxLatitude = mapRectangle.center.latitude + (mapSpan.latitudeDelta / 2)
        
        boundingBox["minLongitude"] = "\(minLongitude)"
        boundingBox["maxLongitude"] = "\(maxLongitude)"
        boundingBox["minLatitude"] = "\(minLatitude)"
        boundingBox["maxLatitude"] = "\(maxLatitude)"
        
        return boundingBox
    }
    
    //pinTap is used to either delete a pin or to display the image associated with a pin.
    
    func pinTap(view: MKAnnotationView) {
        let newString = "\(view.annotation!.subtitle! ?? "random String")"
        myPin = nil
        if deleteSwitch.isOn == false {
                for item in NewPins.sharedInstance().pins {
                    if item.randomString == newString && newString != "random String" {
                        myPin = item
                        performSegue(withIdentifier: "showDetailViewController", sender: self)
                        return
                    } else {
                        if item.url == newString && newString != "random url" {
                            myPin = item
                            performSegue(withIdentifier: "showDetailViewController", sender: self)
                            return
                        }
                    }
                }
            return
        }
        if deleteSwitch.isOn{
            updateMapView(view: view, string: newString)
        }
    }
    
    // updateMapView is used to remove annotations from the mapView.
    
    func updateMapView(view: MKAnnotationView, string: String){
        self.mapView.removeAnnotation(view.annotation!)
        var counter: Int = 0
        for item in Annotations.sharedInstance().annotations {
            if item.subtitle == string {
                Annotations.sharedInstance().annotations.remove(at: counter)
            } else {
                counter = counter + 1
            }
        }
        setupNewPin(view: view, string: string)
    }
    
    // setUpPin creates a NewPin object with the correct randomString and URL and passes that object to updateReconcileStatusOfPinAtDelete.
    
    func setupNewPin(view: MKAnnotationView, string: String){
        let newString = string
        var newPin = NewPin()
        var counter: Int = 0
        for item in NewPins.sharedInstance().pins {
            if item.randomString == newString && item.randomString != "random string" {
                newPin.url = item.url
                newPin.randomString = newString
                newPin.image = item.image
                newPin.note = item.note
                newPin.userID = item.userID
                NewPins.sharedInstance().pins.remove(at: counter)
                RetrieveAndStore.sharedInstance().updateReconcileStatusOfPinAtDelete(newPin){
                    self.addAnnotations()
                }
            } else if item.url == newString && item.url != "random url" {
                newPin.url = item.url
                newPin.randomString = item.randomString
                newPin.image = item.image
                newPin.note = item.note
                newPin.userID = item.userID
                NewPins.sharedInstance().pins.remove(at: counter)
                RetrieveAndStore.sharedInstance().updateReconcileStatusOfPinAtDelete(newPin) {
                    self.addAnnotations()
                }
            }
            counter = counter + 1
        }
        self.addAnnotations()
    }
    
    // prepare(for segue) is used to set up the LoginViewController or the DetailViewController.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailViewController" {
            navigationController?.setNavigationBarHidden(false, animated: true)
            var newViewController = segue.destination as! DetailViewController
            newViewController.pin = myPin
        }
        if segue.identifier == "showLoginViewController" {
            var newViewController = segue.destination as! LoginViewController
            newViewController.signOut = true
        }
    }

}

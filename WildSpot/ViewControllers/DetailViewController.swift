//
//  DetailViewController.swift
//  WildSpot
//
//  Created by John Fandrey on 8/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseDatabase

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var newMapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextView!
    
    var pin: NewPin!
    var annotation = MKPointAnnotation()
    var user = WildSpotUser()
    var errorImage: UIImage!
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
    }
    
    override func viewDidLoad() {
        errorImage = UIImage(named: "Error Message")
        setupMap()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateView()
        self.removeFromParentViewController()
    }
    
    func updateView(){
        newMapView.delegate = nil
        newMapView.removeFromSuperview()
        imageView.removeFromSuperview()
        textField.removeFromSuperview()
        newMapView = nil
    }
    
// setupMap centers the mapView on the pin location and adds the pin to the map.
    
    func setupMap(){
        newMapView.isUserInteractionEnabled = false
        newMapView.delegate = self
        centerMapOnLocation(location: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), span: 5)
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        newMapView.addAnnotation(annotation)
        updateImage()
    }
    
    // updateImage determines if the pin has image data associated with it already.  If it does, then the imageView is updated to display the image associated with that pin.  If not, then the image data is retrieved from flickr or firebase storage and the image is updated.
    
    func updateImage(){
        DispatchQueue.main.async {
            self.activityView.activityIndicatorViewStyle = .gray
            self.activityView.startAnimating()
            self.activityView.isHidden = false
        }
        if pin.image != nil {
            let newImage: UIImage!
            if let newImage = pin.image {
                DispatchQueue.main.async {
                    self.imageView.image = self.pin.image!
                    self.activityView.stopAnimating()
                    self.activityView.isHidden = true
                    self.updateTextField()
                }
                return
            }
        } else {
            if pin.userID == UserName.sharedInstance().userName && checkCoreDataForPin(randomString: pin.randomString) != nil {
                let newPin = checkCoreDataForPin(randomString: self.pin.randomString)
                if let image = UIImage(data: newPin!.image!) {
                    DispatchQueue.main.async {
                        if self.imageView == nil {
                            return
                        }
                        self.imageView.image = UIImage(data: (newPin?.image!)!)
                        self.activityView.stopAnimating()
                        self.activityView.isHidden = true
                        self.updateTextField()
                    }
                    return
                } else {
                    RetrieveImagesForDetailViewController.sharedInstance().retrieveImageFromInternet(randomString: self.pin.randomString, self)
                }
            } else if pin.image == nil {
                RetrieveImagesForDetailViewController.sharedInstance().retrieveImageFromInternet(randomString: pin.randomString, self)
            }
        }
    }
    
    // checkCoreData for Pin is used to prevent the app from loading images from the internet if the images are stored on the device.  
    
    func checkCoreDataForPin(randomString: String)->Pin?{
        if randomString != "random string" && randomString != "random url" {
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            let newPredicate = NSPredicate(format: "randomString == %@", pin.randomString)
            fetchRequest.predicate = newPredicate
            if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
                if result.count == 0 {
                    return nil
                } else {
                    if result[0].image != nil {
                        pin.userID = result[0].userID!
                        pin.note = result[0].note
                        return result[0]
                    } else {
                        return nil
                    }
                }
            }
        }
        return nil
    }
    
    // displayAlertController displays an alert controller that communicates an error message to the user.
    
    func displayAlertController(){
        let alertController = UIAlertController(title: "Error", message: "WildSpot was unable to download the image for this spot. Please return to the Map using the arrow in the top left corner of this screen and try again later.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // updateTextField is called to update the textField using the note stored with the pin.
    
    func updateTextField(){
        if self.pin.note != nil && self.pin.note != "note" {
            DispatchQueue.main.async {
                if self.pin.userID == "userID" {
                    self.textField.text = ""
                } else {
                    self.textField.text = self.pin.userID + ": " + self.pin.note
                }
            }
        } else {
            DispatchQueue.main.async {
                self.textField.text = ""
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D, span: Float){
        var coordinateRegion: MKCoordinateRegion!
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(span), longitudeDelta: CLLocationDegrees(span))
        coordinateRegion = MKCoordinateRegionMake(location, span)
        newMapView.setRegion(coordinateRegion, animated: true)
    }
    
    // // The function retrieveImageFromURL is passed a URL.  The function downloads the image from the received URL and saves the image data.
    
    
    
    // This delegate method returns an MKAnnotation view.  The method also determines the color of the pin.  Pins from Flickr are blue.  Pins from Firebase and CoreData are green.
    
    func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // I used the PinSample App and the Ray Wenderlich tutorial updated by Audrey Tam to get the delegate function below to work properly.  I was having issues with getting pins to be displayed instead of balloons or markers.
        let identifier = "marker"
        var view: MKPinAnnotationView
        if let dequeuedView = newMapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
            if self.pin.url.contains("flickr") || self.pin.url.starts(with: "https"){
                view.pinTintColor = UIColor.blue
                return view
            } else {
                view.pinTintColor = UIColor.green
                return view
            }
            return view
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            if self.pin.url.contains("flickr") || self.pin.url.starts(with: "https"){
                view.pinTintColor = UIColor.blue
                return view
            } else {
                view.pinTintColor = UIColor.green
                return view
            }
            view.animatesDrop = false
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
        return view
    }
    
}

//
//  MapViewController.swift
//  WildSpot

// use myPin as a placeholder, but create a newPin at the last opportunity and then add that to the Pins.sharedInstance().pins array.
//
//  Created by John Fandrey on 8/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var signOut: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var search: UIBarButtonItem!
    @IBOutlet weak var zoomIn: UIBarButtonItem!
    @IBOutlet weak var zoomOut: UIBarButtonItem!
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    @IBOutlet weak var deleteSwitch: UISwitch!
    @IBOutlet weak var mapActivityView: UIActivityIndicatorView!
    
    var myPin: NewPin?!
    var newPin: NewPin!
    var annotations = [MKPointAnnotation]()
    var locationManager = CLLocationManager()
    var searchTerms: String? = nil
    var displayName = String()
    var user: WildSpotUser!
    
    // updateView is used to get rid of the mapView once the MapViewController has disappeared.
    
    func updateView(){
        mapView.delegate = nil
        mapView.removeFromSuperview()
        mapView = nil
    }

    @IBAction func signOut(_ sender: Any) {
        updateView()
    }
    
    // searchFlick is called when the 'search' button is pressed.
    
    @IBAction func searchFlickr(_ sender: Any) {
        displaySearchBox(self)
    }
    
    // switchFlipped is called when the deleteSwitch is moved from one position to another.
    
    @IBAction func switchFlipped(_ sender: Any) {
        if deleteSwitch.isOn {
            search.isEnabled = false
            self.mapView.removeAnnotations(self.mapView.annotations)
            annotations.removeAll()
            let alertController = UIAlertController(title: "Delete Pins", message: "Pins tapped while the switch is 'on' will be deleted. Tap the switch again to avoid deleteing pins.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            let completion: (_ array: [Pin])->() = { array in
                for item in array {
                    if item.reconcile != "delete" && item.url?.contains("flickr") == false {
                        RetrieveAndStore.sharedInstance().generateNewPin(pin: item)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate.latitude = item.latitude
                        annotation.coordinate.longitude = item.longitude
                        annotation.subtitle = item.randomString
                        self.annotations.append(annotation)
                    }
                }
                self.mapView.addAnnotations(self.annotations)
            }
            RetrieveAndStore.sharedInstance().generateAnnotationsFromCoreData(completion)
        } else {
            if self.mapView.annotations.count != 0 {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            search.isEnabled = true
            Annotations.sharedInstance().annotations.removeAll()
            removeFlickrResults()
            self.addAnnotations()
        }
    }
    
    // zoomIn is called when the zoomIn button is pressed.
    
    @IBAction func zoomIn(_ sender: Any) {
        let span: MKCoordinateSpan = mapView.region.span
        let newSpanLatitude: Double = span.latitudeDelta / 1.25
        let newSpanLongitude: Double = span.longitudeDelta / 1.25
        let newSpan: MKCoordinateSpan = MKCoordinateSpanMake(newSpanLatitude, newSpanLongitude)
        centerMapOnLocation(mapView.centerCoordinate, newSpan)
    }
    
    // zoomOut is called when the zoomOut button is pressed.
    
    @IBAction func zoomOut(_ sender: Any) {
        let span: MKCoordinateSpan = mapView.region.span
        let newSpanLatitude: Double = span.latitudeDelta / 0.75
        let newSpanLongitude: Double = span.longitudeDelta / 0.75
        let newSpan: MKCoordinateSpan = MKCoordinateSpanMake(newSpanLatitude, newSpanLongitude)
        centerMapOnLocation(mapView.centerCoordinate, newSpan)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapActivityView.isHidden = true
        newPin = NewPin()
        NewPin.sharedInstance().reconcile = ""
        centerMapOnLocation(nil, nil)
        deleteSwitch.isOn = false
        displayName = UserName.sharedInstance().userName
        RetrieveAndStore.sharedInstance().checkForExistingUserEntity(){
            self.addAnnotations()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateAnnotations()
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // addAnnotations is used to reset the annotations on the map and to add only the current annotations.
    
    func addAnnotations(){
        DispatchQueue.main.async {
            Annotations.sharedInstance().annotations.removeAll()
            if self.mapView.annotations.count != 0 {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            self.generateAnnotations()
            self.annotations = Annotations.sharedInstance().annotations
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    // generateAnnotations is used to create annotations from the NewPins.sharedInstance().pins array.  If the deleteSwitch is in the on position then pins from Flickr do not have an annotation added to the Annotations.sharedInstance().annotations array.  If the deleteSwitch is in the off position then an annotation is added to  Annotations.sharedInstance().annotations for each pin in NewPins.sharedInstance().pins.
    
    func generateAnnotations(){
        RetrieveAndStore.sharedInstance().retrievePinsFromCoreData()
        for pin in NewPins.sharedInstance().pins {
            var annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            annotation.subtitle = pin.randomString
            if deleteSwitch.isOn {
                if pin.userID == UserName.sharedInstance().userName && pin.reconcile != "delete" {
                        Annotations.sharedInstance().annotations.append(annotation)
                    }
                }
            if deleteSwitch.isOn == false && pin.reconcile != "delete" {
                if pin.url.contains("flickr") == false {
                    var duplicate: Bool = false
                    for annotation in Annotations.sharedInstance().annotations {
                        if annotation.subtitle == pin.randomString {
                            duplicate = true
                        }
                    }
                    if duplicate == false {
                        Annotations.sharedInstance().annotations.append(annotation)
                    }
                } else {
                    Annotations.sharedInstance().annotations.append(annotation)
                }
            }
        }
    }
    
    // displaySearchBox is called when the search button is pressed.  This function displays an alert controller with a text field where a user can enter an animal to search flickr for.
    
    func displaySearchBox(_ sender: UIViewController){
        let alertController = UIAlertController(title: "Search", message: "Enter the animal you're searching for", preferredStyle: .alert)
        alertController.addTextField { (textField) -> Void in
            textField.delegate = self
            textField.placeholder = "Enter your search terms"
        }
        alertController.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.default,handler: { UIAlertAction in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.annotations.removeAll()
            self.removeFlickrResults()
            self.downloadPhotos(alertController.textFields![0].text!)
        }))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        sender.present(alertController, animated: true, completion: nil)
    }
    
    // removeFlickrResults removes all pins from Flickr from the NewPins.sharedInstance().pins array.
    
    func removeFlickrResults(){
        var count: Int = 0
        var intArray = [Int]()
        for pin in NewPins.sharedInstance().pins {
            if pin.url != "https://farm2.staticflickr.com//1968//43710112580_5bc3b0f5b0.jpg" && pin.url.starts(with: "https://") && pin.url.contains("flickr"){
                intArray.insert(count, at: 0)
            }
            count += 1
        }
        for item in intArray {
            NewPins.sharedInstance().pins.remove(at: item)
        }
    }
    
    // longPressAddPin is called when the user presses and holds the mapView.  This function saves the location of the tap and calls displayNoteBox.
    
    @IBAction func longPressAddPin(_ sender: Any) {
        if longPress.state == .began && deleteSwitch.isOn == false {
            let touchLocation = longPress.location(in: self.mapView) // adds the location on the view it was pressed
            // I found an example for converting the location of the touch to a latitude and longitude coordinate at https://medium.com/@williamliu_19785/drawing-on-mkmapview-daceab966177 in a post by William Liu dated March 13, 2017.
            let touchLocationCoordinate: CLLocationCoordinate2D = mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
            // will get coordinates
            newPin.latitude = touchLocationCoordinate.latitude
            newPin.longitude = touchLocationCoordinate.longitude
             // Sets the coordinates of 'additionalPin' to the coorindates of the points touched on the map.
            displayNoteBox()
        }
    }
    
    // updateMapView  updates the annotations on the mapView.
    
    func updateMapView(){
        self.annotations = Annotations.sharedInstance().annotations
        if mapView.annotations.count != 0 && self.annotations.count != 0 {
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(self.annotations)
                return
        }} else if annotations.count != 0 {
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
            }
        } else {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    // displayError is used to display an errors to the user using an alert controller.
    
    func displayError(_ info: String, _ sender: UIViewController) {         // Code for displaying an alert notification was obtained at https://www.ioscreator.com/tutorials/display-alert-ios-tutorial-ios10.  The tutorial for displaying this type of alert was posted by Arthur Knopper on January 10, 2017.
        let alertController = UIAlertController(title: "Error", message: info, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        sender.present(alertController, animated: true, completion: nil)
    }
    
    // displayNoteBox is called after the user has longPressed on the mapView. This function displays an alert controller with a text field that allows the user to enter some information about the photo their posting.
    
    func displayNoteBox(){
        var alertController = UIAlertController(title: "Note", message: "Enter some information about the animal you've spotted and the photo you took.", preferredStyle: .alert)
        alertController.addTextField { (textField) -> Void in
            textField.delegate = self
            textField.placeholder = "Describe your Wild Spot here"
        }
        alertController.addAction(UIAlertAction(title: "Enter", style: UIAlertActionStyle.default,handler: { UIAlertAction in
            if alertController.textFields?[0].text != nil {
                self.newPin.note = (alertController.textFields?[0].text!)!
                self.newPin.userID = UserName.sharedInstance().userName
                self.selectImage()
                alertController.dismiss(animated: true, completion: nil)
            } else {
                self.newPin.note = ""
                self.selectImage()
               alertController.dismiss(animated: true, completion: nil)
            }
             // Calls the addPin function with the additionalPin.
        }))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}


//
//  MapViewController.swift
//  WildSpot

// use myPin as a placeholder, but create a newPin at the last opportunity and then add that to the Pins.sharedInstance().pins array.
//
//  Created by John Fandrey on 8/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import Firebase
import FirebaseAuthUI
import FirebaseDatabaseUI

// Add code to remove map from view controller from superview and to set the mapView delegate to nil when the view disappears.

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var signOut: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var search: UIBarButtonItem!
    @IBOutlet weak var camera: UIBarButtonItem!
    @IBOutlet weak var zoomIn: UIBarButtonItem!
    @IBOutlet weak var zoomOut: UIBarButtonItem!
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    
    var myPin = NewPin()
    var annotations = [MKPointAnnotation]()
    var locationManager = CLLocationManager()
    var searchTerms: String? = nil
    var displayName = String()
    var dataController: DataController!
    
    // Create a variable for a pickerController.
            // Set the delegate of the picker controller to the viewController.

    
    @IBAction func searchFlickr(_ sender: Any) {
        displaySearchBox(self)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        // Creates an action for the takePhoto button.
        takePhoto()
    }
    
    @IBAction func signOut(_ sender: Any) {
        
    }
    // Code for getting user loaction was obtained from an example provided by GurdevSingh94.  The code can be found at https://github.com/GurdevSingh94/SwiftUserLocation/blob/master/getUserLocation/getUserLocation/ViewController.swift.  A YouTube video with an explanation of the code can be found at https://www.youtube.com/watch?v=WDrdtdMYgWc.
    
    @IBAction func zoomIn(_ sender: Any) {
        let span: MKCoordinateSpan = mapView.region.span
        let newSpanLatitude: Double = span.latitudeDelta / 1.25
        let newSpanLongitude: Double = span.longitudeDelta / 1.25
        let newSpan: MKCoordinateSpan = MKCoordinateSpanMake(newSpanLatitude, newSpanLongitude)
        centerMapOnLocation(mapView.centerCoordinate, newSpan)
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        let span: MKCoordinateSpan = mapView.region.span
        let newSpanLatitude: Double = span.latitudeDelta / 0.75
        let newSpanLongitude: Double = span.longitudeDelta / 0.75
        let newSpan: MKCoordinateSpan = MKCoordinateSpanMake(newSpanLatitude, newSpanLongitude)
        centerMapOnLocation(mapView.centerCoordinate, newSpan)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(nil, nil)
        camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) // code for checking availability of camera provided by Udacity in curriculum for MemeMe app.
        dataController = DataController.sharedInstance()
        displayName = UserName.sharedInstance().userName
        checkConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func checkConnection() -> Bool {
        let newBool: Bool!
        let newBlock = {
            
        }
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
                RetrieveAndStore.sharedInstance().configureDatabase()
                RetrieveAndStore.sharedInstance().configureStorage()
            } else {
                print("Not connected")
            }
        })
    }
    
    
    func updateView(){
        mapView.delegate = nil
        mapView.removeFromSuperview()
        mapView = nil
    }
    
    func configureMapView(){
        mapView.showsUserLocation = true
    }
    
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
    
    func removeFlickrResults(){
        var count: Int = 0
        for pin in NewPins.sharedInstance().pins {
            if pin.url != nil && (pin.url?.starts(with: "https://"))!{
                NewPins.sharedInstance().pins.remove(at: count)
                count = count - 1
            }
            count += 1
        }
    }
    
    @IBAction func longPressAddPin(_ sender: Any) {
        if longPress.state == .began {
            let touchLocation = longPress.location(in: self.mapView) // adds the location on the view it was pressed
            // I found an example for converting the location of the touch to a latitude and longitude coordinate at https://medium.com/@williamliu_19785/drawing-on-mkmapview-daceab966177 in a post by William Liu dated March 13, 2017.
            let touchLocationCoordinate: CLLocationCoordinate2D = mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
            // will get coordinates
            NewPin.sharedInstance().latitude = touchLocationCoordinate.latitude
            NewPin.sharedInstance().longitude = touchLocationCoordinate.longitude
             // Sets the coordinates of 'additionalPin' to the coorindates of the points touched on the map.
            displayNoteBox()
        }
    }
    
    func updateMapView(){
        cleanPinsArray()
        print("I'm updating the mapView")
        print("There are \(self.annotations.count) in the annotations array.")
        if mapView.annotations.count != 0 && self.annotations.count != 0 {
            DispatchQueue.main.async {
                print("I'll add and remove some annotations.")
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(self.annotations)
                return
        }} else if annotations.count != 0 {
            DispatchQueue.main.async {
                print("I'll just add some annotations.")
                self.mapView.addAnnotations(self.annotations)
                print("The map now has the following annotations")
                print(self.mapView.annotations.count)
                self.mapView.setNeedsDisplay()
            }
        } else {
            return
        }
    }
    
    func cleanPinsArray(){
        var newArray = NewPins.sharedInstance().pins
        var newerArray = Array(Set(newArray))
        NewPins.sharedInstance().pins = newerArray
        print("The number of items in the newArray was \(newArray.count) and the number of items in the newerArray was \(newerArray.count)")
    }
    
    func displayError(_ info: String, _ sender: UIViewController) {         // Code for displaying an alert notification was obtained at https://www.ioscreator.com/tutorials/display-alert-ios-tutorial-ios10.  The tutorial for displaying this type of alert was posted by Arthur Knopper on January 10, 2017.
        let alertController = UIAlertController(title: "Error", message: info, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        sender.present(alertController, animated: true, completion: nil)
    }
    
    func displayNoteBox(){
        var alertController = UIAlertController(title: "Note", message: "Enter some information about the animal you've spotted and the photo you took.", preferredStyle: .alert)
        alertController.addTextField { (textField) -> Void in
            textField.delegate = self
            textField.placeholder = "Describe your Wild Spot here"
        }
        alertController.addAction(UIAlertAction(title: "Enter", style: UIAlertActionStyle.default,handler: { UIAlertAction in
            if alertController.textFields?[0].text != nil {
                NewPin.sharedInstance().note = alertController.textFields?[0].text!
                self.addPin()
                alertController.dismiss(animated: true, completion: nil)
            } else {
                NewPin.sharedInstance().note = ""
                self.addPin()
               alertController.dismiss(animated: true, completion: nil)
            }
             // Calls the addPin function with the additionalPin.
        }))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}


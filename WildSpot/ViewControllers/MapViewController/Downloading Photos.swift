//
//  Downloading Photos.swift
//  WildSpot
//
//  Created by John Fandrey on 9/14/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension MapViewController {
    
    // downloadPhotos uses the search string taken from the user and calls the FlickrClient.sharedInstance().getPhotos function.
    
    func downloadPhotos(_ searchTerms: String?){
        self.mapActivityView.isHidden = false
        self.mapActivityView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 50) {
            self.displayError("The request timed out.  Please try again later.  It's possible you still need to supply an api key for using Flickr.", self)
            self.mapActivityView.isHidden = true
            self.mapActivityView.stopAnimating()
            return
        }
        if searchTerms != nil {
            FlickrClient.sharedInstance().getPhotos(searchTerms!, getBoundingBox()){(data: AnyObject?, error: String?) in
                if error != nil {
                    let errorText: String = error!
                    DispatchQueue.main.async  {
                        self.displayError(errorText, self)
                        self.addAnnotations()
                        self.mapActivityView.isHidden = true
                        self.mapActivityView.stopAnimating()
                    }
                    return
                }
                if data != nil {
                    if let sessionData = data as! [String:Any]? {
                        if let status = sessionData["stat"] as! String? {
                            if status == "ok" {
                                let sessionDictionary = sessionData["photos"] as! [String:Any]  // Set a dictionary of type [String:String] equal to sessionData["session"].
                                let photos = sessionDictionary["photo"]
                                // Set the sessionID equal to sessionDictionary["id"].
                                self.populateFlickrArray(photos: photos as! [[String : Any]])
                                return
                            } else {
                                if status == "fail" {
                                    if let message = sessionData["message"] as! String? {
                                        return
                                    }
                                    return
                                }
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    // populateFlickrArray takes an array of dictionaries and uses each dictionary to add a NewPin to the NewPins.sharedInstance().pins array.  
    
    func populateFlickrArray(photos: [[String:Any]]){
        for item in photos {
            var flickrPin = NewPin()
            flickrPin.url = "random url"
            flickrPin.latitude = 40
            flickrPin.longitude = -95
            if let url: String = (item["url_m"] as! String).replacingOccurrences(of: "\\", with: "") {
                flickrPin.url = url
                flickrPin.randomString = url
            } else {
                flickrPin.url = "https://farm2.staticflickr.com/1919/44862256782_7d45ff4df7.jpg"
            }
            
            if let latitude: String = item["latitude"] as? String {
                flickrPin.latitude = Double(latitude)!
            } else {
                flickrPin.latitude = 40
            }
            
            if let longitude: String = item["longitude"] as? String {
                flickrPin.longitude = Double(longitude)!
            } else {
                flickrPin.longitude = -95
            }
            NewPins.sharedInstance().pins.append(flickrPin)
        }
        self.addAnnotations()
        DispatchQueue.main.async {
            self.mapActivityView.isHidden = true
            self.mapActivityView.stopAnimating()
        }
    }
    
}

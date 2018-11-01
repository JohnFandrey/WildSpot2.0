//
//  Adding Pins and Picking Images.swift
//  WildSpot
//
//  Created by John Fandrey on 9/14/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

extension MapViewController {
    
    // updateAnnotations is used to generate a new set of annotation form NewPins.sharedInstance().pins.
    
    func updateAnnotations(){
        annotations.removeAll()
        self.mapView.removeAnnotations(self.mapView.annotations)
        Annotations.sharedInstance().annotations.removeAll()
        for pin in NewPins.sharedInstance().pins {
            if pin.reconcile != "delete" {
                let newAnnotation = MKPointAnnotation()
                newAnnotation.coordinate.latitude = pin.latitude
                newAnnotation.coordinate.longitude = pin.longitude
                if (pin.randomString != "random string") {
                    newAnnotation.subtitle = pin.randomString
                } else if (pin.url != "random url") {
                    newAnnotation.subtitle = pin.url
                }
                Annotations.sharedInstance().annotations.append(newAnnotation)
            }
        }
        updateMapView()
    }
    
    // getRandomNumber is used to support the generateRandomString function.
    
    func getRandomNumber(_ max: Int) -> Int {
        var randomNumber = Int()
        randomNumber = Int(arc4random_uniform(UInt32(max)))
        return randomNumber
    }
    
    // generateRandomString is used to generate a randomString 25 characters in length with a possible 62 characters for each position in the string.  The randomString is used to differentiate individual Pins and to provide an identifier in the firebase realtime database.
    
    func generateRandomString() -> String {
        let characterArray: [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
        let indexMax: Int = characterArray.count - 1
        var count: Int = 0
        var newString = ""
        while count < 25 {
            let randomNumber = getRandomNumber(indexMax)
            let newCharacter: String = characterArray[randomNumber]
            newString.append(newCharacter)
            count += 1
        }
        return newString
    }
    
}

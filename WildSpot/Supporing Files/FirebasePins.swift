//
//  FirebasePins.swift
//  WildSpot
//
//  Created by John Fandrey on 10/4/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FirebasePins: NSObject {
    
    class func sharedInstance() -> FirebasePins {  // Declare a function that creates an instance of NewPin.  This function returns an instance of NewPin, thus the other objects can access the functions in NewPin through this function.
        
        struct Singleton {
            static var sharedInstance = FirebasePins()
        }
        return Singleton.sharedInstance
    }
    
    var firebasePins: [DataSnapshot]! = []
    
}


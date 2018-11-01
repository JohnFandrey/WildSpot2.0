//
//  newPin.swift
//  WildSpot
//
//  Created by John Fandrey on 9/28/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class NewPin: NSObject {
    
    class func sharedInstance() -> NewPin {  // Declare a function that creates an instance of NewPin.  This function returns an instance of NewPin, thus the other objects can access the functions in NewPin through this function.
        
        struct Singleton {
            static var sharedInstance = NewPin()
        }
        return Singleton.sharedInstance
    }
    
    var image: UIImage?
    var latitude: Double = 40.0
    var longitude: Double = 95.0
    var note: String! = ""
    var url: String! = "random url"
    var randomString: String! = "random string"
    var userID: String = "userID"
    var reconcile: String = ""
    
}

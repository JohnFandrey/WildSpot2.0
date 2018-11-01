//
//  Pins.swift
//  WildSpot
//
//  Created by John Fandrey on 9/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation

class NewPins: NSObject {
    
    class func sharedInstance() -> newPins {  // Declare a function that creates an instance of FlickrClient.  This function returns an instance of FlickrClient, thus the other objects can access the functions in FlickrClient through this function.
        struct Singleton {
            static var sharedInstance = newPins()
        }
        return Singleton.sharedInstance
    }
    
    var pins = [newPin]()
    
}
 

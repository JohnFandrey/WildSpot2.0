//
//  Pins.swift
//  WildSpot
//
//  Created by John Fandrey on 9/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation

class NewPins: NSObject {
    
    class func sharedInstance() -> NewPins {  // Declare a function that creates an instance of NewPins.  This function returns an instance of NewPins, thus the other objects and view controllers can access the array of NewPins through this function.
        struct Singleton {
            static var sharedInstance = NewPins()
        }
        return Singleton.sharedInstance
    }
    
    var pins = [NewPin]()
    
}
 

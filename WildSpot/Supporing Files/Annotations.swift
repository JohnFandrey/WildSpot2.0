//
//  Annotations.swift
//  WildSpot
//
//  Created by JohnFandrey on 10/4/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class Annotations: NSObject {
    
    class func sharedInstance() -> Annotations {  // Declare a function that creates an instance of Annotations.  This function returns an instance of Annotations, thus the other objects and view controllers can access the array of annotations through this function.
        struct Singleton {
            static var sharedInstance = Annotations()
        }
        return Singleton.sharedInstance
    }
    
    var annotations = [MKPointAnnotation]()
    
}

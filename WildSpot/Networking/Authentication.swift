//
//  Authentication.swift
//  WildSpot
//
//  Created by John Fandrey on 8/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class Authentication: NSObject {
    
    class func sharedInstance() -> Authentication {  // Declare a function that creates an instance of Authentication.  This function returns an instance of Authentication, thus the other objects can access the values in Authentication through this function.
        
        struct Singleton {
            static var sharedInstance = Authentication()
        }
        return Singleton.sharedInstance
    }
    
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    
}

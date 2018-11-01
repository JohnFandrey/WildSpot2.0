//
//  userName.swift
//  WildSpot
//
//  Created by JohnFandrey on 10/2/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation

class UserName: NSObject {
    
    class func sharedInstance() -> UserName {  // Declare a function that creates an instance of UserName.  This function returns an instance of UserName, thus the other objects and view controllers can access the userName string in UserName through this function.
        struct Singleton {
            static var sharedInstance = UserName()
        }
        return Singleton.sharedInstance
    }
    
    var userName = String()
    
}

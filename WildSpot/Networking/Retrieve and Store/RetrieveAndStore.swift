//
//  RetrieveAndStore.swift
//  WildSpot
//
//  Created by John Fandrey on 8/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class RetrieveAndStore: NSObject {
    
    var ref = DatabaseReference()
    var storageRef = StorageReference()
    var spots: [DataSnapshot]! = []
    var remoteConfig: RemoteConfig!
    let imageCache = NSCache<NSString, UIImage>()
    var keyboardOnScreen = false
    var placeholderImage = UIImage(named: "ic_account_circle")
    var displayName = String()
    var user = WildSpotUser(context: DataController.sharedInstance().viewContext)    // let dataController = DataController.sharedInstance()
    var _refHandle: DatabaseHandle!
    var _refHandleDelete: DatabaseHandle!
    var runCount: Int = 0
    
    class func sharedInstance() -> RetrieveAndStore {  // Declare a function that creates an instance of RetrieveAndStore.  This function returns an instance of RetrieveAndStore, thus the other objects can access the functions in RetrieveAndStore through this function.
        struct Singleton {
            static var sharedInstance = RetrieveAndStore()
        }
        return Singleton.sharedInstance
    }
    
    // checkForDuplicatePins ensures that no duplicates are added to the NewPins.sharedInstance().pins array. 
    
    func checkForDuplicatePins(pin: NewPin)->Bool{
        for item in NewPins.sharedInstance().pins {
            if pin.randomString == item.randomString {
                return true
            }
        }
        return false
    }
    
    // generateDictionary is passed a newPin and returns a dictionary of type [String:Any].
    
    func generateDictionary(_ newPin: NewPin) -> [String:Any]{
        let newDictionary: [String:Any] = ["latitude":newPin.latitude ?? 40, "longitude":newPin.longitude ?? -100, "userID":newPin.userID ?? "unknown", "url":newPin.url ?? "URL  Goes Here","randomString":newPin.randomString ?? "random identifier", "note":newPin.note  ?? "cool animal", "reconcile":""]
        return newDictionary
    }


}

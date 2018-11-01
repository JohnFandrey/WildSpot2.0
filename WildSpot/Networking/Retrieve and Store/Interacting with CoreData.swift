//
//  Interacting with CoreData.swift
//  WildSpot
//
//  Created by JohnFandrey on 10/17/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import CoreData
import MapKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

extension RetrieveAndStore {
    
    // checkForExistingUserEntity uses the string stored at UserName.sharedInstance().userName  to determine the value for 'displayName'.  The function then uses a fetchRequest and a predicate to find a WildSpotUser entity with a name that matches the UserName.sharedInstance().userName.  value.  If a match is found then the 'user' value is set to the value found by the fetch request.  If no value is found then a new WildSpotUser entity is created with a name equal to the displayName.
    
    func checkForExistingUserEntity(_ completion: (() -> Void)? = nil) {
        let fetchRequest: NSFetchRequest<WildSpotUser> = WildSpotUser.fetchRequest()
        displayName = UserName.sharedInstance().userName
        let newPredicate = NSPredicate(format: "name == %@", UserName.sharedInstance().userName)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
            let newResult = (result as NSArray).filtered(using: newPredicate)
            if newResult.count != 0 && newResult.count == 1{
                user = newResult[0] as! WildSpotUser
            } else {
                user = WildSpotUser(context: DataController.sharedInstance().viewContext)
                user.name = displayName
                try? DataController.sharedInstance().viewContext.save()
            }
        }
        RetrieveAndStore.sharedInstance().configureDatabase(completion)
    }
    
    // retrievePinsFromCoreData uses a fetch request and a predicate to retrieve all the pins with a userID that matches the displayName.  If pins are found then newPins are generated.  The function also checks for connectivity to firebase.  If the app is connected to firebase then the function configureDatabase is called.  If the app is not connected to firebase the function calls the completion handler it was passed.
    
    func retrievePinsFromCoreData(_ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "userID == %@", UserName.sharedInstance().userName)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
            for item in result {
                generateNewPin(pin: item)
            }
        }
        if completion != nil {
            completion!()
        }
    }
    
    // generateAnnotationsFromCoreData uses a fetch request and a predicate to pull all the pins from CoreData with a userID that matches the UserName.sharedInstance().userName.  A completion handler is used to create an array of annotations from the pins retrieved.
    
    func generateAnnotationsFromCoreData(_ completion: ((_ array: [Pin]) -> Void)? = nil){
        Annotations.sharedInstance().annotations.removeAll()
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "userID == %@", UserName.sharedInstance().userName)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
            completion!(result)
        } else {
            return
        }
    }
    
    // storeUserPins is used to add pins downloaded from firebase to the persistent store.  This is done so that if 1) a user has previously uploaded pins to firebase from another device; or 2) the persistent store on the current device has been cleared, that the pins uploaded to firebase can be downloaded to the device and saved in the persistent store.  The function is passed a NewPin object.  The function then uses a fetchRequest and a predicate to retrieve pins from the persistent store with a userName that matches the displayName.  The randomString of each pin retrieved is then checked against the randomString of the NewPin object passed to the function.  If a match is found the function returns true.  If no match is found then the function generatePin is called and passed the NewPin object passed to storeUserPins.  The function generatePin then saves the pin to CoreData ensuring that the pin is now persisted on the device.
    
    func storeUserPins(pin: NewPin) -> Bool {
        if pin.userID == displayName {
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            let newPredicate = NSPredicate(format: "userID == %@", displayName)
            fetchRequest.predicate = newPredicate
            if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
                if result.count != 0 {
                    for item in result {
                        if pin.randomString == item.randomString {
                            if item.image == nil {
                                retrieveImageFromFirebaseStorage(url: item.url ?? "random url")
                            }
                            return true
                        }
                    }
                }
              generatePin(newPin: pin)
            }
        }
        return false
    }
    
    // generateNewPin is passed a Pin object, generates a NewPin object, and appends a new pin to the NewPins.sharedInstance().pins array.
    
    func generateNewPin(pin: Pin){
        var newPin = NewPin()
        newPin.latitude = pin.latitude
        newPin.longitude = pin.longitude
        newPin.userID = pin.userID!
        newPin.note = pin.note!
        newPin.randomString = pin.randomString!
        newPin.reconcile = pin.reconcile!
        newPin.url = pin.url!
        if pin.image != nil {
            newPin.image = UIImage(data: pin.image!)
        }
        if pin.image == nil && newPin.url != nil {
            if let url = URL(string: newPin.url) {
                self.retrieveImageFromURL(url: URL(string: newPin.url)!){
                    newPin.image = NewPin.sharedInstance().image
                }
            }
        }
        if checkForDuplicatePins(pin: newPin) == false {
            NewPins.sharedInstance().pins.append(newPin)
        } else {
            return
        }
    }
    
    // generatePin is passed a NewPin object.  This object is used to generate a Pin object which is saved in CoreData.  
    
    func generatePin(newPin: NewPin) {
        let pin = Pin(context: DataController.sharedInstance().viewContext)
        pin.latitude = newPin.latitude
        pin.longitude = newPin.longitude
        if newPin.note == "note" {
            pin.note = ""
        } else if newPin.note != "note" {
            pin.note = newPin.note
        }
        pin.url = newPin.url
        pin.randomString = newPin.randomString
        pin.reconcile = newPin.reconcile
        pin.user = user
        pin.userID = UserName.sharedInstance().userName
        // user.addToPins(pin)
        if newPin.image != nil {
            pin.image = UIImagePNGRepresentation(newPin.image!)
        } else {
            if NewPin.sharedInstance().image != nil {
                pin.image = UIImagePNGRepresentation(NewPin.sharedInstance().image!)
            } else if pin.url != nil{
                if (pin.url?.starts(with: "gs://"))! {
                    retrieveImageFromFirebaseStorage(url: newPin.url)
                }
            } else {
                pin.image = UIImagePNGRepresentation(UIImage(named: "Error Message")!)
            }
        }
            try? DataController.sharedInstance().viewContext.save()
        }
    
    // checkForPinsToAdd searches the Core Data for pins that have "add" as their reconcile status.  
    
    func checkForPinsToAdd(_ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "reconcile == %@", "add")
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            for item in result {
                var newPin = NewPin()
                newPin.url = item.url ?? "random url"
                newPin.randomString = item.randomString ?? "random string"
                newPin.image = UIImage(data: item.image!)
                RetrieveAndStore.sharedInstance().uploadPhotoToFirebase(newPin, completion)
            }
        }
        self.retrievePinsFromCoreData(completion)
    }
    
    

}

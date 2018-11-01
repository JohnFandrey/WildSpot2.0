//
//  Interacting with Firebase.swift
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
    
    // convertFirebasePinstoNewPins is used to convert the array of DataSnapshots retrieved from firebase to NewPins.  The app checks to see if pins that match the displayName are saved in CoreData.  If there is no match then the pin is added to CoreData so that pin is persisted on the device.
    
    func convertFirebasePinstoNewPins(snapshot: DataSnapshot){
            let pin = snapshot.value as! [String:Any]
            let newPin = NewPin()
            newPin.latitude = pin["latitude"] as! Double
            newPin.longitude = pin["longitude"] as! Double
            newPin.note = pin["note"] as! String
            newPin.randomString = pin["randomString"] as! String
            newPin.url = pin["url"] as! String
            newPin.userID = pin["userID"] as! String
            newPin.reconcile = pin["reconcile"] as! String
            if storeUserPins(pin: newPin) == false && checkForDuplicatePins(pin: newPin) == false {
                NewPins.sharedInstance().pins.append(newPin)
            }
    }
    
    // deletePhotoFromFirebaseStorage is passed a NewPin object.  The url stored at the NewPin's url property is used to generate a Firebase Storage reference.  Firebase's delete function is then uses to delete the photo stored at the reference location.
    
    func deletePhotoFromFirebaseStorage(_ pin: NewPin){
        let deleteRef = Storage.storage().reference(forURL: pin.url)
        // Delete the file
        deleteRef.delete { error in
            if let error = error {
            } else {
            }
        }
    }
    
    // configureDatabase sets up the app's connection to the Firebase Realtime Database and downloads a Snapshot of all the data in the database.
    
    func configureDatabase(_ completion: (() -> Void)? = nil){
        FirebasePins.sharedInstance().firebasePins.removeAll()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        ref.child("spots").observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children {
                FirebasePins.sharedInstance().firebasePins.append(item as! DataSnapshot)
                self.convertFirebasePinstoNewPins(snapshot: item as! DataSnapshot)
            }
            RetrieveAndStore.sharedInstance().checkForPinsToDeleteAtLaunch(completion!)
            completion!()
        }
        )
        _refHandleDelete = ref.child("spots").observe(.childRemoved) { (snapshot: DataSnapshot) in
            self.removePinFromNewPinsAtFirebaseDelete(snapshot, completion)
            }
        completion!()
    }
    
    func setRefHandle(_ completion: (() -> Void)? = nil){
        _refHandle = ref.child("spots").observe(.childAdded) { (snapshot: DataSnapshot) in
            FirebasePins.sharedInstance().firebasePins.append(snapshot)
            self.convertFirebasePinstoNewPins(snapshot: snapshot)
            completion!()
        }
    }
    
}

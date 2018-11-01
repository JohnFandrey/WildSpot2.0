//
//  Deleting a Pin.swift
//  WildSpot
//
//  Created by John Fandrey on 10/19/18.
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

extension RetrieveAndStore {
    
    // updateReconcileStatusOfPinAtDelete is called once a pin has been removed from Firebase Storage and the Firebase Realtime database.
    
    func updateReconcileStatusOfPinAtDelete(_ pin: NewPin, _ completion: (()->Void)?){
        let string = pin.randomString!
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", string)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            for item in result {
                item.reconcile = "delete"
                try? DataController.sharedInstance().viewContext.save()
            }
        }
        removePinFromArrayOfNewPins(pin, completion)
    }
    
    // removePinFromArrayOfNewPins uses a randomString to find the correct pin to remove from the NewPins.sharedInstance().pins array.
    
    func removePinFromArrayOfNewPins(_ pin: NewPin, _ completion: (()->Void)?){
        var counter: Int = 0
        for item in NewPins.sharedInstance().pins {
            if pin.randomString! == item.randomString! && pin.randomString != "random string"{
                NewPins.sharedInstance().pins.remove(at: counter)
                removePhotoFromFirebaseStorageAtDelete(pin, completion)
                return
            }
            counter = counter + 1
        }
        removePhotoFromFirebaseStorageAtDelete(pin, completion)
        return
    }
    
    // removePhotoFromFirebaseStorageAtDelete removes the image associated with a spot from Firebase Storage.
    
    func removePhotoFromFirebaseStorageAtDelete(_ pin: NewPin, _ completion: (()->Void)?){
        if pin.url.starts(with: "gs://wildspot"){
            var newBool: Bool!
            let deleteRef = Storage.storage().reference(forURL: pin.url)
            // Delete the file
            deleteRef.delete { error in
                if let error = error {
                    if error.localizedDescription.contains("does not exist") {
                        self.removePinFromRealtimeDatabaseAtDelete(pin, completion)
                    }
                    return
                } else {
                    self.removePinFromRealtimeDatabaseAtDelete(pin, completion)
                }
            }
        } else {
            removePinFromRealtimeDatabaseAtDelete(pin, completion)
        }
    }
    
    // removePinFromRealtimeDatabaseAtDelete removes a pin from Firebase Realtime Database.
    
    func removePinFromRealtimeDatabaseAtDelete(_ pin: NewPin, _ completion: (()->Void)?){
        ref.child("spots").child(pin.randomString).removeValue() {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                if error.localizedDescription.contains("does not exist") {
                    self.removePinFromCoreDataAtDelete(pin: pin, completion)
                }
            } else {
                self.removePinFromCoreDataAtDelete(pin: pin, completion)
            }
        }
    }
    
    // removePinFromCoreData uses a fetch request and a predicate to fid pins with a randomString that matches the randomString of the pin passed to the function.  If a match is found then the matching pin is deleted and the context is saved.
    
    func removePinFromCoreDataAtDelete(pin: NewPin, _ completion: (()->Void)?){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", pin.randomString)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
            for item in result {
                DataController.sharedInstance().viewContext.delete(item)
                try? DataController.sharedInstance().viewContext.save()
                completion!()
                return
            }
        }
        completion!()
    }
    
    // removePinFromNewPinsAtFirebaseDelete is called when an entry is deleted from firebase.  This function helps to ensure that the spots stored on the device are consistent with what is in Firebase.
    
    func removePinFromNewPinsAtFirebaseDelete(_ pin: DataSnapshot, _ completion: (()->Void)?){
        var counter: Int = 0
        for item in NewPins.sharedInstance().pins {
            if item.randomString == getStringFromFirebasePinPinAtFirebaseDelete(pin) {
                NewPins.sharedInstance().pins.remove(at: counter)
                removePinFromCoreDataAtFirebaseDelete(item.randomString, completion)
            } else {
                counter = counter + 1
            }
        }
        return
    }
    
    // getStringFromFirebasePinPinAtFirebaseDelete returns the randomString associated with the deleted pin.
    
    func getStringFromFirebasePinPinAtFirebaseDelete(_ pin: DataSnapshot)->String {
        let snapshot = pin.value as! [String:Any]
        let randomString: String = snapshot["randomString"] as! String
        return randomString
    }
    
    // removePinFromCoreDataAtFirebaseDelete removes the appropriate pin from Core Data using a randomString.  
    
    func removePinFromCoreDataAtFirebaseDelete(_ randomString: String, _ completion: (()->Void)?){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", randomString)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
            if result.count == 0 {
                completion!()
                return
            }
            for item in result {
                DataController.sharedInstance().viewContext.delete(item)
                try? DataController.sharedInstance().viewContext.save()
                completion!()
                return
            }
        } else {
            completion!()
        }
    }

}

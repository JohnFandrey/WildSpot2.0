//
//  App Launch.swift
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
    
    // checkForPinsToDeleteAtLaunch fetches pins from CoreData that have "delete" as their reconcile status.  The app then attempts to delete the images associated with those pins from Firebase Storage, the data from Firebase Realtime database, and the entry from CoreData.
    
    func checkForPinsToDeleteAtLaunch(_ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "reconcile == %@", "delete")
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            if result.count == 0 {
                checkForPinsToAddAtLaunch(completion)
            }
            for item in result {
                var newPin = NewPin()
                newPin.url = item.url ?? "random url"
                newPin.randomString = item.randomString ?? "random string"
                removePhotoFromFirebaseStorageAtLaunch(newPin, completion)
            }
        } else {
            checkForPinsToAddAtLaunch(completion)
        }
    }
    
    // removePhotoFromFirebaseStorageAtLaunch attempts to remove the photo associated with the pin from Firebase Storage.
    
    func removePhotoFromFirebaseStorageAtLaunch(_ pin: NewPin, _ completion: (()->Void)?){
        if pin.url.starts(with: "gs://wildspot"){
            var newBool: Bool!
            let deleteRef = Storage.storage().reference(forURL: pin.url)
            // Delete the file
            deleteRef.delete { error in
                if let error = error {
                    if error.localizedDescription.contains("does not exist"){
                        self.removePinFromRealtimeDatabaseAtLaunch(pin, completion)
                        return
                    } else {
                       self.checkForPinsToAddAtLaunch(completion)
                        return
                    }
                } else {
                    self.removePinFromRealtimeDatabaseAtLaunch(pin, completion)
                    return
                }
            }
        } else {
            removePinFromRealtimeDatabaseAtLaunch(pin, completion)
            return
        }
    }
    
    // removePinFromRealtimeDatabaseAtLaunch deletes the entry in Firebase Realtime Database associated with the passed pin.
    
    func removePinFromRealtimeDatabaseAtLaunch(_ pin: NewPin, _ completion: (()->Void)?){
        ref.child("spots").child(pin.randomString).removeValue() {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                if error.localizedDescription.contains("does not exist"){
                    self.removePinFromCoreDataAtLaunch(pin, completion)
                }
                self.checkForPinsToAdd(completion)
            } else {
                self.removePinFromCoreDataAtLaunch(pin, completion)
            }
        }
    }
    
    // removePinFromCoreDataAtLaunch uses a fetch request and a predicate to find pins with a randomString that matches the randomString of the pin passed to the function.  If a match is found then the matching pin is deleted and the context is saved.
    
    func removePinFromCoreDataAtLaunch(_ pin: NewPin, _ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", pin.randomString)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
            for item in result {
                DataController.sharedInstance().viewContext.delete(item)
                try? DataController.sharedInstance().viewContext.save()
            }
        }
        checkForPinsToAddAtLaunch(completion)
    }
    
    // checkForPinsToAddAtLaunch searches Core Data for pins that have "add" as their reconcile status.  If pins are found, then the app attempts to upload the associated image to Firebase Storage, attempts to add an entry to Firebase Realtime Database, and changes the reconcile status of the pin if those attempts are successful.
    
    func checkForPinsToAddAtLaunch(_ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "reconcile == %@", "add")
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            if result.count == 0 {
                retrievePinsFromCoreDataAtLaunch(completion)
                return
            }
            for item in result {
                var newPin = NewPin()
                if item.url != nil {
                    newPin.url = item.url
                }
                if item.url == nil {
                    item.url = "random url"
                }
                newPin.url = item.url ?? "random url"
                newPin.randomString = item.randomString
                newPin.latitude = item.latitude
                newPin.longitude = item.longitude
                newPin.note = item.note
                newPin.reconcile = item.reconcile!
                newPin.userID = item.userID!
                if item.image != nil {
                    newPin.image = UIImage(data: item.image!) ?? UIImage(named: "Error Message")
                    uploadPhotoToFirebaseAtLaunch(newPin, completion)
                } else {
                    retrievePinsFromCoreDataAtLaunch(completion)
                }
            }
        } else {
            retrievePinsFromCoreDataAtLaunch(completion)
        }
    }
    
    // uploadPhotoToFirebaseAtLaunch attempts to upload the image associated with a pin to Firebase Storage.
    
    func uploadPhotoToFirebaseAtLaunch(_ pin: NewPin, _ completion: (() -> Void)? = nil){
        var newPin = pin
        // code for setting timer using GCD obtained at https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer in a post by Paul Hudson dated June 1, 2018.
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
            return
        }
        if newPin.url.starts(with: "gs://wildspot"){
            RetrieveAndStore.sharedInstance().uploadSpotToRealtimeDatabaseAtLaunch(pin, completion)
            return
        } else {
            let imagePath = "wild_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let photoData: Data = UIImagePNGRepresentation(pin.image ?? UIImage(named: "Error Message")!) ?? UIImagePNGRepresentation(UIImage(named: "Error Message")!)!
            self.storageRef.child(imagePath).putData(photoData, metadata: metadata){(metadata, error) in
                if error == nil {
                    newPin.url = self.storageRef.child((metadata?.path)!).description
                    RetrieveAndStore.sharedInstance().updateURLAtLaunch(newPin, completion)
                    return
                } else if error != nil {
                    return
                }
            }
        }
    }
    
    // uploadSpotToRealTimeDatabaseAtLaunch attempts to upload the data associated with a pin to Firebase Realtime Database.
    
    func uploadSpotToRealtimeDatabaseAtLaunch(_ pin: NewPin, _ completion: (() -> Void)? = nil){
        // code for setting timer using GCD obtained at https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer in a post by Paul Hudson dated June 1, 2018.
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
            return
        }
        self.ref.child("spots").child(pin.randomString).setValue(self.generateDictionary(pin)){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                completion!()
                return
            } else {
                var newPin: NewPin = pin
                newPin.reconcile = ""
                self.updateReconcileStatusOfPinAtLaunch(newPin, completion)
                return
            }
        }
        return
    }
    
    // retrivePinsFromCoreDataAtLaunch retrieves all the pins associated with a the UserName entered by the user.
    
    func retrievePinsFromCoreDataAtLaunch(_ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "userID == %@", UserName.sharedInstance().userName)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest) {
            for item in result {
                if item.reconcile == "" {
                    if compareFirebasePinsToCoreData(pin: item) == true {
                        generateNewPin(pin: item)
                    } else {
                        DataController.sharedInstance().viewContext.delete(item)
                    }
                } else if item.reconcile == "add" {
                    generateNewPin(pin: item)
                }
            }
            completion!()
        } else {
            completion!()
            }
        setRefHandle(completion)
        }
    
    // compareFirebasePinsToCoreData is a function that helps to ensure that a spot that was deleted on one device while the current device was offline, is removed from CoreData.  This is done so that entries in Core Data are up to date and that old images are no longer taking up space on the device.
    
    func compareFirebasePinsToCoreData(pin: Pin)->Bool{
        if FirebasePins.sharedInstance().firebasePins.count != 0 {
            for item in FirebasePins.sharedInstance().firebasePins {
                let snapshotPin = item.value as! [String:Any]
                let randomString = snapshotPin["randomString"] as! String
                if randomString == pin.randomString {
                    return true
                }
            }
            removePinFromNewPins(randomString: pin.randomString!)
            return false
        } else if FirebasePins.sharedInstance().firebasePins.count == 0 {
            return true
        }
            return true
    }
    
    func removePinFromNewPins(randomString: String){
        var counter: Int = 0
        for item in NewPins.sharedInstance().pins {
            if item.randomString == randomString {
                NewPins.sharedInstance().pins.remove(at: counter)
                return
            } else {
                counter = counter + 1
            }
        }
    }
    
    // update URLAtLaunch saves the url obtained when uploading an image to firebase to firebase pin.
    
    func updateURLAtLaunch(_ pin: NewPin, _ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", pin.randomString)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            for item in result {
                item.url = pin.url
                try? DataController.sharedInstance().viewContext.save()
            }
        }
        RetrieveAndStore.sharedInstance().uploadSpotToRealtimeDatabaseAtLaunch(pin, completion)
    }
    
    // updateReconcileStatusOfPinAtLaunch changes the reconcile status of pins in Core Data.
    
    func updateReconcileStatusOfPinAtLaunch(_ pin: NewPin, _ completion: (() -> Void)? = nil){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", pin.randomString)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            for item in result {
                item.reconcile = ""
                try? DataController.sharedInstance().viewContext.save()
            }
        }
        // retrievePinsFromCoreDataAtLaunch(completion)
    }
    
    
    
    
}

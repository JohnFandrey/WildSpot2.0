//
//  Adding a Pin.swift
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
    
    // addPinToCoreData saves a NewPin object into the persistent store.
    
    func addPinToCoreData(_ pin: NewPin, completion: (()->Void)?){
        generatePin(newPin: pin)
        completion!()
        RetrieveAndStore.sharedInstance().uploadPhotoToFirebase(pin, completion)
    }
    
    // uploadPhotoToFirebase uploads a photo to Firebase Storage.
    
    func uploadPhotoToFirebase(_ pin: NewPin, _ completion: (()->Void)?){
        var newPin = pin
        if newPin.url.starts(with: "gs://wildspot"){
            RetrieveAndStore.sharedInstance().uploadSpotToRealtimeDatabase(pin, completion)
            return
        } else {
            let imagePath = "wild_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let photoData: Data = UIImagePNGRepresentation(pin.image ?? UIImage(named: "Error Message")!) ?? UIImagePNGRepresentation(UIImage(named: "Error Message")!)!
            // code for setting timer using GCD obtained at https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer in a post by Paul Hudson dated June 1, 2018.
            DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
                return
            }
            self.storageRef.child(imagePath).putData(photoData, metadata: metadata){(metadata, error) in
                if error == nil {
                    newPin.url = self.storageRef.child((metadata?.path)!).description
                    RetrieveAndStore.sharedInstance().updateURL(newPin, completion)
                    return
                } else if error != nil {
                    completion!()
                    return
                }
            }
        }
    }
    
    // uploadSpotToRealtimeDatabase adds a 'spot' to the realtime database.
    
    func uploadSpotToRealtimeDatabase(_ pin: NewPin, _ completion: (()->Void)?){
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
                self.updateReconcileStatusOfPin(newPin)
                completion!()
                return
            }
        }
    }
    
    // updateReconcileStatusOfPin changes the 'reconcile' status of the pin in Core Data.
    
    func updateReconcileStatusOfPin(_ pin: NewPin){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", pin.randomString)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            for item in result {
                item.reconcile = ""
                try? DataController.sharedInstance().viewContext.save()
            }
        }
    }
    
    // updateURL saves the URL associated with a NewPin object to the correct pin in CoreData.  
    
    func updateURL(_ pin: NewPin, _ completion: (()->Void)?){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "randomString == %@", pin.randomString)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            for item in result {
                item.url = pin.url
                try? DataController.sharedInstance().viewContext.save()
            }
        }
        RetrieveAndStore.sharedInstance().uploadSpotToRealtimeDatabase(pin, completion)
    }
    
    
    
}

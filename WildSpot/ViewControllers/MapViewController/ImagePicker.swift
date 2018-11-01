//
//  ImagePickerController.swift
//  WildSpot
//
//  Created by John Fandrey on 9/18/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension MapViewController {
    
    // selectImage is used to initialize and present a UIImagePickerController and to present the initalized UIImagePickerController.
    
    func selectImage(){
        let pickerController = UIImagePickerController()                                // Create a variable for a pickerController.
        pickerController.delegate = self                                                // Set the delegate of the picker controller to the viewController.
        pickerController.sourceType = .photoLibrary                                     // Set the source to the photo Library.
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {            // Creates a function dealing with a canceled image selection.
        picker.dismiss(animated: true, completion: nil)
    }
    
    // The imagePickerController function below allows a user to pick an image.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker.sourceType == .photoLibrary {
            let myImage = UIImagePickerControllerOriginalImage                              // Creates a variable myImage.
            if let image = info[myImage] as? UIImage, let photoData = UIImageJPEGRepresentation(image, 0.9) {
                self.newPin.image = image
                self.newPin.randomString = generateRandomString()
                self.newPin.reconcile = "add"
                self.newPin.url = "random url"
                self.newPin.userID = UserName.sharedInstance().userName
                RetrieveAndStore.sharedInstance().addPinToCoreData(self.newPin){
                    self.addAnnotations()
                }
                // Need to remove call to uploadPhoto
               // RetrieveAndStore.sharedInstance().uploadPhoto(photoData: photoData){self.updateAnnotations()}// Conditinally unwraps image.
                picker.dismiss(animated: true, completion: nil)// dismisses the imagePickerController.
                // dismisses the imagePickerController.
            } else {
                picker.dismiss(animated: true, completion: nil) // dismisses the imagePickerController.
            }
        }
    }
    
}

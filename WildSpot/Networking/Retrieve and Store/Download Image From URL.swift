//
//  Download Image From URL.swift
//  WildSpot
//
//  Created by JohnFandrey on 10/17/18.
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
    
    // retrieveImageFromURL is used to retrieve an image from Flickr.
    
    func retrieveImageFromURL(url: URL, completion: @escaping (()->Void)) {
        // I found an example for saving an image as a Binary attribute a youtube video at https://www.youtube.com/watch?v=f0IpkDHccTw.  The video is part of a raywenderlich.com tutorial and was posted on December 1, 2017.
        // I also found an example for retrieving an image from a URL at https://www.simplifiedios.net/get-image-from-url-swift-3-tutorial/ in a post by Belal Khan dated July 3, 2017.
        // Udacity has also provided an example for downloading data from the a URL
        // I have used both of the examples above to get data retrieved from Flickr to be stored properly in Core Data.
        let imageURL = url
        var downloadedData: Data!
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if error == nil {
                downloadedData = data
                if downloadedData != nil {
                    NewPin.sharedInstance().image = UIImage(data: downloadedData!)
                    completion()
                } else {
                    return
                }
            }
        }
        task.resume()
    }
    
    func retrieveImageFromFirebaseStorage(url: String){
        Storage.storage().reference(forURL: url).getData(maxSize: INT64_MAX){ (data, error) in
            guard error == nil else {
                return
            }
        let messageImage = UIImage.init(data: data!, scale: 50)
            self.saveImageInCoreData(image: messageImage ?? UIImage(named: "Error Message")!, url: url)
        }
    }
    
    func saveImageInCoreData(image: UIImage, url: String){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let newPredicate = NSPredicate(format: "url == %@", url)
        fetchRequest.predicate = newPredicate
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            if result.count == 0 {
                return
            }
            for item in result {
                item.image = UIImagePNGRepresentation(image)
                try? DataController.sharedInstance().viewContext.save()
            }
        }
    }

}

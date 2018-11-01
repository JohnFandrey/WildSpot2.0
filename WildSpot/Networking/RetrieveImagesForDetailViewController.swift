//
//  RetrieveImagesForDetailViewController.swift
//  WildSpot
//
//  Created by JohnFandrey on 10/24/18.
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

// RetrieveImagesForDetailViewController is a class that is used to store the networking code that is needed to download images associated with pins.  The code downloads the images from Flickr or Firebase as needed.

class RetrieveImagesForDetailViewController: NSObject {
    
    class func sharedInstance() -> RetrieveImagesForDetailViewController {  // Declare a function that creates an instance of FlickrClient.  This function returns an instance of FlickrClient, thus the other objects can access the functions in FlickrClient through this function.
        struct Singleton {
            static var sharedInstance = RetrieveImagesForDetailViewController()
        }
        return Singleton.sharedInstance
    }
    
    // retrieveImageFromInternet is used to retrieve images from Firebase or call the retrieveImageFromURL function is the image is from flickr.
    
    func retrieveImageFromInternet(randomString: String, _ viewController: DetailViewController){
        if viewController.pin.url.contains("flickr") || (viewController.pin.url.starts(with: "https")) {
            self.retrieveImageFromURL(URL(string:viewController.pin.url)!, viewController)
        } else {
            // code for setting timer using GCD obtained at https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer in a post by Paul Hudson dated June 1, 2018.
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                if viewController.imageView == nil {
                    return
                }
                if viewController.imageView.image != nil {
                    return
                }
                viewController.imageView.image = viewController.errorImage
                viewController.activityView.stopAnimating()
                viewController.activityView.isHidden = true
                viewController.updateTextField()
                return
            }
            let imageURL = viewController.pin.url
            Storage.storage().reference(forURL: imageURL!).getData(maxSize: INT64_MAX){ (data, error) in
                guard error == nil else {
                    if viewController.imageView == nil {
                        return
                    }
                    viewController.imageView.image = viewController.errorImage
                    viewController.activityView.stopAnimating()
                    viewController.activityView.isHidden = true
                    viewController.updateTextField()
                    return
                }
                let messageImage = UIImage.init(data: data!, scale: 50)
                DispatchQueue.main.async {
                    if viewController.imageView == nil {
                        return
                    }
                    viewController.imageView?.image = messageImage
                    viewController.activityView.stopAnimating()
                    viewController.activityView.isHidden = true
                    viewController.updateTextField()
                    return
                }
            }
        }
    }
    
    func retrieveImageFromURL(_ url: URL, _ viewController: DetailViewController) {
        // I found an example for saving an image as a Binary attribute a youtube video at https://www.youtube.com/watch?v=f0IpkDHccTw.  The video is part of a raywenderlich.com tutorial and was posted on December 1, 2017.
        // I also found an example for retrieving an image from a URL at https://www.simplifiedios.net/get-image-from-url-swift-3-tutorial/ in a post by Belal Khan dated July 3, 2017.
        // Udacity has also provided an example for downloading data from the a URL
        // I have used both of the examples above to get data retrieved from Flickr to be stored properly in Core Data.
        // code for setting timer using GCD obtained at https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer in a post by Paul Hudson dated June 1, 2018.
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            if viewController.imageView == nil {
                return
            }
            if viewController.imageView.image != nil {
                return
            }
            viewController.imageView.image = viewController.errorImage
            viewController.activityView.stopAnimating()
            viewController.activityView.isHidden = true
            viewController.updateTextField()
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                let downloadedData = data
                if downloadedData != nil {
                    DispatchQueue.main.async {
                        viewController.pin.image =  UIImage(data: downloadedData!)
                        if viewController.imageView == nil {
                            return
                        }
                        viewController.imageView.image = viewController.pin.image
                        viewController.activityView.stopAnimating()
                        viewController.activityView.isHidden = true
                        viewController.updateTextField()
                        viewController.updateTextField()
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        if viewController.imageView == nil {
                            return
                        }
                        viewController.imageView.image = viewController.errorImage
                        viewController.updateTextField()
                        viewController.activityView.isHidden = true
                        viewController.activityView.stopAnimating()
                        viewController.updateTextField()
                        return
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    if viewController.imageView == nil {
                        return
                    }
                    if viewController.imageView.image != nil {
                        return
                    }
                    if viewController.imageView == nil {
                        return
                    }
                    viewController.imageView.image = viewController.errorImage
                    viewController.updateTextField()
                    viewController.activityView.isHidden = true
                    viewController.activityView.stopAnimating()
                    viewController.updateTextField()
                    return
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    
}

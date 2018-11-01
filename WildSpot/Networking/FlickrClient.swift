//
//  FlickrClient.swift
//  WildSpot
//
//  Created by John Fandrey on 8/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient: NSObject {
    
    class func sharedInstance() -> FlickrClient {  // Declare a function that creates an instance of FlickrClient.  This function returns an instance of FlickrClient, thus the other objects can access the functions in FlickrClient through this function.
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func getPhotos(_ searchTerm: String, _ boundingBox: [String:String], _ completionHandlerForGetPhotos: @escaping (_ data: AnyObject?, _ error: String?) -> Void){
        // This function requests photos from flickr and stores the data in an array.
        // I used code from the OnTheMap app and code provided by Udacity from the OnTheMap lessons to write the code below.
        // Code for generating a random number was provided by Udacity in the lessons regarding the Flick Finder app.
        
        let maxLongitude: String = boundingBox["maxLongitude"]!
        let maxLatitude: String = boundingBox["maxLatitude"]!
        let minLongitude: String = boundingBox["minLongitude"]!
        let minLatitude: String = boundingBox["minLatitude"]!
        
        var newString = removeSpaces(searchTerm)
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=***********************&bbox=\(minLongitude)%2C\(minLatitude)%2C\(maxLongitude)%2C\(maxLatitude)&safe_search=1&text=\(newString)&extras=url_m%2C+geo&per_page=100&page=1&format=json&nojsoncallback=1"
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        _ = self.taskForMethod(request, completionHandlerForGetPhotos) // Calls the taskForMethod function and passes the desired completion handler to the function.
    }
    
    // removeSpaces replaces spaces with safe characters.  
    
    func removeSpaces(_ searchString: String) -> String {
        return searchString.replacingOccurrences(of: " ", with: "%20")
    }
    
    // The taskForMethod function sets up and executes a session data task.
    
    func taskForMethod(_ request: URLRequest, _ completionHandlerForMethod: @escaping (_ data: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        // This function returns a URLSessionDataTask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard (error == nil) else {
                self.checkError(error, completionHandler: completionHandlerForMethod) // calls a function to check the error returned.
                return
            }
            guard (data == nil) else {
                self.convertData(data!, completionHandler: completionHandlerForMethod) // calls a function to conver the data returned by the function.
                return
            }
        }
        task.resume()
        return task
    }
    
    // The function convertData is passed the JSON data returned by the taskForMethod function and a completion handler, the function converts the returned JSON data to a dictionary that can be used in swift, the function then passes the data to the completion handler.
    
    func convertData(_ data: Data, completionHandler: @escaping (_ data: AnyObject?, _ error: String?) -> Void) {
        // Function for converting JSON data to usable dictionary.
        var parsedData: [String:AnyObject]! = nil                                                                                                // Initialize object for storing parsed JSON data.
        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]                            // Attempt to store parsed JSON data in parsedData object.
            completionHandler(parsedData as AnyObject, nil) // Calls the completionHandler with the parsed data.
        } catch {
            completionHandler(nil, "The app was unable to parse the data returned by the server.  Please contact Udacity to report this issue.")
            // Calls the completion handler with an error message if the data could not be parsed.
        }
    }
    
    // The function check error handles any erros returned in the taskForMethod function.
    
    func checkError(_ error: Error?, completionHandler: @escaping (_ data: AnyObject?, _ error: String?) -> Void) {
        if let errorText: String = error as? String {                                                                   // If there was an error check to see if it can be stored as a string.
            completionHandler(nil, "There was an error with your request: \(errorText)")    // If the error can be stored as a string, then call the completion handler with the error string.
            return
        } else {                                                                        // If the error cannot be stored as a string, then check to see if it can be respresented as an NSError.
            if let error = error as NSError? {                          // If the error can represented as an NSerror then check to see if the error.code value is -1001 or -999.
                if error.code == -1001 || error.code == -999 {                                        // If the error.code value is -1001 or -999 then call the completion handler with the appropriate error message.
                    completionHandler(nil, "The request timed out.  Please check your internet connection and try again.")
                    return
                } else {
                    completionHandler(nil, "Your request produced the following error code: \(error.code). Please contact the developer to inform them that you received this code.") // If the error code is not -1001 or -999 then call the completion handler with the code returned.
                    return
                }
            }
            return
        }
    }
    
    // The function displayError will display an alert controller with error information.  This provides the user with error information instead of just printing error information to the console.
    
    func displayError(_ info: String, _ sender: UIViewController) {         // Code for displaying an alert notification was obtained at https://www.ioscreator.com/tutorials/display-alert-ios-tutorial-ios10.  The tutorial for displaying this type of alert was posted by Arthur Knopper on January 10, 2017.
        let alertController = UIAlertController(title: "Error", message: info, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        sender.present(alertController, animated: true, completion: nil)
    }
    
    
    
}

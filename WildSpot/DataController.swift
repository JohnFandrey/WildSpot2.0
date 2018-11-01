//
//  DataController.swift
//  WildSpot
//
//  Created by John Fandrey on 9/28/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import CoreData

class DataController: NSObject {
    
    class func sharedInstance() -> DataController {  // Declare a function that creates an instance of DataController.  This function returns an instance of DataController, thus the other objects can access the functions in Data through this function.
        struct Singleton {
            static var sharedInstance = DataController(modelName: "WildSpot")
        }
        return Singleton.sharedInstance
    }
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: ( () -> Void)? =  nil) {
        persistentContainer.loadPersistentStores(){ storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
}

//
//  DataController.swift
//  VirtualTourist
//
//  Created by Asmahero on ١٦ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import Foundation
import CoreData
class DataController {
    //persistenceContainer instance with let ( this is the container of the data)
    let persistenceContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistenceContainer.viewContext
    }
    ///End of ontainer

    // we will pass the model of data name
    init (modelName: String){
        persistenceContainer = NSPersistentContainer(name: modelName)
    }
    
   
    // It is only accept completion as a parameter. We want to call the function after checking there is no error. That is why we pass the commpletion as a parameter and git it type of closure and give it type of optional with default value nil
    func load(completion:(() -> Void)? = nil ){
        persistenceContainer.loadPersistentStores{ storeDescription , error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            // here is to call the function after passing error
            completion?()
        }
    }
}

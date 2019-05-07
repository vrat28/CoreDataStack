//
//  CoreDataManager.swift
//  CoreDataStack
//
//  Created by Varun Rathi on 08/05/19.
//  Copyright © 2019 Varun Rathi. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {

    private lazy var managedObjectModel :NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource:self.modelName, withExtension:"momd") else {
            fatalError("Unable to find Data Model")
        }
        guard let managedModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to load model")
        }
        return managedModel
    }()
    
    private lazy var persistantStoreCoordinator : NSPersistentStoreCoordinator = {
        
        let persistantCord = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = self.modelName!+".sqlite"
        let documentDirectoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistantStoreCoordinatorPath = documentDirectoryPath.appendingPathComponent(storeName)
        do {
            
            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                           NSInferMappingModelAutomaticallyOption : true]
            
            try persistantCord.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistantStoreCoordinatorPath, options: options)
            
            
        } catch {
            fatalError("fatal error")
        }
        return persistantCord
    }()
    
    
    
   public private(set) lazy var privateManagedObjectContext:NSManagedObjectContext = {
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.persistentStoreCoordinator = self.persistantStoreCoordinator
        return managedContext
        
    }()
    
    
    public private(set) lazy var mainManagedObjectContext:NSManagedObjectContext = {
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.privateManagedObjectContext
        return managedObjectContext
    }()
    
    public func save() {
        
        mainManagedObjectContext.performAndWait {
            
            do {
                
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
                
            } catch {
                fatalError("Main Context Failed to Save")
            }
        }
        
        privateManagedObjectContext.perform {
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
                
                
            } catch {
                fatalError("private Context Failed to Save")
            }
        }
    }
    
    
    public let modelName:String?
    init(modelName:String) {
        self.modelName = modelName
    }

}

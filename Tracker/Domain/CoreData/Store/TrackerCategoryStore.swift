//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.04.2023.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreProtocol {
    func createCategory(_ name: String, with trackerCoreData: TrackerCoreData) throws
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    private let managedContext: NSManagedObjectContext
    
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func createCategory(_ name: String, with trackerCoreData: TrackerCoreData) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",
                                             #keyPath(TrackerCategoryCoreData.header),
                                             name)
        let result = try managedContext.fetch(fetchRequest)
        
        if let category = result.first {
            category.addToTrackerList(trackerCoreData)
        } else {
            let category = TrackerCategoryCoreData(context: managedContext)
            category.header = name
            category.addToTrackerList(trackerCoreData)
        }
        
        try managedContext.save()
    }
}

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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

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
        
        appDelegate.saveContext()
    }
    
    func findTracker(withName name: String) -> (category: TrackerCategoryCoreData, tracker: TrackerCoreData)? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let tracker = results.first {
                if let category = tracker.category {
                    return (category, tracker)
                }
            }
        } catch {
            print("Error fetching TrackerCoreData: \(error)")
        }
        
        return nil
    }

}

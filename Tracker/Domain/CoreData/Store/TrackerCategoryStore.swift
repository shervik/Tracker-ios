//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.04.2023.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreProtocol {
    func createCategory(_ name: String)
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    private let managedContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.managedContext = context
    }
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("Could not convert delegate to AppDelegate")
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    func createCategory(_ name: String) {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@",
                                             #keyPath(TrackerCategoryCoreData.header),
                                             name)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            if result.isEmpty {
                let newCategory = TrackerCategoryCoreData(context: managedContext)
                newCategory.header = name
                try managedContext.save()
            }
        } catch {
            preconditionFailure("Error fetching or saving TrackerCategoryCoreData: \(error)")
        }
    }
}

//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.04.2023.
//

import CoreData
import UIKit

protocol TrackerRecordStoreProtocol {
    func updateRecord(_ record: TrackerRecord, date: Date)
    func getCountRecords(for id: UUID) -> Int
    func isTrackerCompleted(_ id: UUID, with date: Date) -> Bool
}

final class TrackerRecordStore: NSObject {
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
}

// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    
    func updateRecord(_ record: TrackerRecord, date: Date) {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let predicateForDate = NSPredicate(format: "date == %@", date as CVarArg)
        let predicateForId = NSPredicate(format: "id == %@", record.id as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateForDate, predicateForId])
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            if let existingRecord = result.first {
                managedContext.delete(existingRecord)
            } else {
                let newItem = TrackerRecordCoreData(context: managedContext)
                newItem.id = record.id
                newItem.date = date
            }
            
            try managedContext.save()
        } catch {
            preconditionFailure("Error fetching or saving TrackerRecordCoreData: \(error)")
        }
    }
    
    func getCountRecords(for trackerId: UUID) -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId.uuidString)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.count
        } catch {
            preconditionFailure("Error fetching TrackerRecordCoreData: \(error)")
        }
    }
    
    func isTrackerCompleted(_ id: UUID, with date: Date) -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let predicateForId = NSPredicate(format: "id == %@", id as CVarArg)
        let predicateForDate = NSPredicate(format: "date == %@", date as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateForId, predicateForDate])

        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.isEmpty ? false : true
        } catch {
            preconditionFailure("Error fetching TrackerRecordCoreData: \(error)")
        }
        
    }
}

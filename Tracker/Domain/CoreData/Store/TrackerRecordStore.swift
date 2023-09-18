//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.04.2023.
//

import CoreData
import UIKit

protocol TrackerRecordStoreProtocol {
    func updateRecord(_ record: TrackerCoreData, date: Date) throws
    func getCountRecords(for id: UUID) -> Int
    func isTrackerCompleted(_ id: UUID, with date: Date) -> Bool
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    private let managedContext: NSManagedObjectContext

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func updateRecord(_ record: TrackerCoreData, date: Date) throws {
        guard let id = record.id else { return }

        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let predicateForDate = NSPredicate(format: "date == %@", date as NSDate)
        let predicateForId = NSPredicate(format: "id == %@", id.uuidString)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateForDate, predicateForId])

        let result = try managedContext.fetch(fetchRequest)
        
        if let existingRecord = result.first {
            managedContext.delete(existingRecord)
        } else {
            let item = TrackerRecordCoreData(context: managedContext)
            item.id = record.id
            item.date = date
            item.tracker = record
        }
        
        try managedContext.save()
    }
    
    func getCountRecords(for id: UUID) -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.count
        } catch {
            preconditionFailure("Error fetching TrackerRecordCoreData: \(error)")
        }
    }
    
    func isTrackerCompleted(_ id: UUID, with date: Date) -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let predicateForId = NSPredicate(format: "id == %@", id.uuidString)
        let predicateForDate = NSPredicate(format: "date == %@", date as NSDate)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateForId, predicateForDate])

        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.isEmpty ? false : true
        } catch {
            preconditionFailure("Error fetching TrackerRecordCoreData: \(error)")
        }
        
    }
}

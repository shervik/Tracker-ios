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
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    private let managedContext: NSManagedObjectContext

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func updateRecord(_ record: TrackerCoreData, date: Date) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let data = try managedContext.fetch(fetchRequest)
        
        if let removeIndex = data.firstIndex(where:{ $0.date == date && $0.id == record.id }) {
            managedContext.delete(data[removeIndex])
        } else {
            let item = TrackerRecordCoreData(context: managedContext)
            item.id = record.id
            item.date = date
            item.tracker = record
        }
        
        appDelegate.saveContext()
    }
}

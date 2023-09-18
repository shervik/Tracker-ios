//
//  TrackerStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 25.04.2023.
//

import CoreData
import UIKit

protocol TrackerStoreProtocol {
    func createTracker(_ tracker: Tracker) throws -> TrackerCoreData
    func getTracker(with id: UUID) -> TrackerCoreData?
    func getTracker(from trackerCoreData: TrackerCoreData) -> Tracker
}

final class TrackerStore: TrackerStoreProtocol {
    private let managedContext: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let uiScheduleMarshalling = UIScheduleMarshalling()
    
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func createTracker(_ tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: managedContext)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = self.uiColorMarshalling.toHexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = uiScheduleMarshalling.convertToInt(tracker.schedule)
        
        return trackerCoreData
    }
    
    func getTracker(with id: UUID) -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching TrackerCoreData: \(error)")
            return nil
        }
    }
    
    func getTracker(from trackerCoreData: TrackerCoreData) -> Tracker {
        guard let id = trackerCoreData.id,
                  let name = trackerCoreData.name,
                  let colorHex = trackerCoreData.colorHex,
                  let emoji = trackerCoreData.emoji,
                  let schedule = trackerCoreData.schedule
        else { preconditionFailure("Failed to load data") }
        return Tracker(id: id,
                       name: name,
                       color: self.uiColorMarshalling.toColor(from: colorHex),
                       emoji: emoji,
                       schedule: uiScheduleMarshalling.convertToWeekday(schedule))
    }
}

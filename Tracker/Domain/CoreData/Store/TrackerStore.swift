//
//  TrackerStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 25.04.2023.
//

import CoreData
import UIKit


// 1) Создать коллекцию
// 2) добавить трекер в существующую коллекцию
// 3) отдать коллекцию с трекерами
// 4) Отсортировать трекер по имени (отображается коллекция с отсортированными трекерами
// 5) Добавить трекер в выполненные
// 6) Удалить трекер из выполненных

protocol TrackerStoreProtocol {
    func createTracker(_ tracker: Tracker) throws -> TrackerCoreData
    func getTracker(with id: UUID) -> TrackerCoreData?
}

final class TrackerStore: TrackerStoreProtocol {
    private let managedContext: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    //    private let uiScheduleMarshalling = UIScheduleMarshalling()
    private var schedule = NSSet()
    
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func createTracker(_ tracker: Tracker) throws -> TrackerCoreData {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        else { fatalError("Unable to retrieve the AppDelegate") }
                
        let trackerCoreData = TrackerCoreData(context: managedContext)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = self.uiColorMarshalling.toHexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSSet
        
//        for weekDay in tracker.schedule { self.addWeekDay(weekDay) }
//        trackerCoreData.schedule = self.schedule
        
        try managedContext.save()
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
        let tracker = Tracker(
            id: trackerCoreData.id!,
            name: trackerCoreData.name!,
            color: self.uiColorMarshalling.toColor(from: trackerCoreData.colorHex!),
            emoji: trackerCoreData.emoji!,
            schedule: []) // TODO: Populate with actual schedule data
        
        return tracker
    }

    
    private func addWeekDay(_ weekDay: WeekDay) {
        schedule.adding(weekDay)
    }
    
    //    func createTracker(_ tracker: Tracker) {
    //        let item = TrackerCoreData(context: context)
    //        item.id = tracker.id
    //        item.colorHex = self.uiColorMarshalling.hexString(from: tracker.color)
    //        item.emoji = tracker.emoji
    //        item.name = tracker.name
    //        item.schedule = Int32(self.uiScheduleMarshalling.convertToInt(days: tracker.schedule))
    //
    //        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
    //            appDelegate.saveContext()
    //        }
    //    }
    //
    //    func loadData(completion: @escaping ([Tracker]) -> Void) {
    //        let fetchRequest = TrackerCoreData.fetchRequest()
    //        let data = (try? context.fetch(fetchRequest)) ?? [TrackerCoreData]()
    //        let trackers = data.map {
    //            return Tracker(
    //                id: $0.id ?? UUID(),
    //                name: $0.name ?? String(),
    //                color: uiColorMarshalling.color(from: $0.colorHex ?? String()),
    //                emoji: $0.emoji ?? String(),
    //                schedule: uiScheduleMarshalling.convertToWeekday(binary: Int($0.schedule)))
    //        }
    //        completion(trackers)
    //    }
}

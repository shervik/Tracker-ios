//
//  TrackerStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 25.04.2023.
//

import CoreData
import UIKit

struct TrackerStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
    let updatedIndexPaths: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    var currentWeekday: String { get }
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol: AnyObject {
    var delegate: TrackerStoreDelegate? { get set }
    var numberOfSections: Int { get }
    
    func numberOfItemsInSection(_ section: Int) -> Int
    func createTracker(_ tracker: Tracker, in categoryName: String)
    func object(at indexPath: IndexPath) -> Tracker?
    func name(of section: Int) -> String?
    func searchForTracker(by text: String?)
    func deleteTracker(at indexPath: IndexPath)
    func toggleTrackerPin(at indexPath: IndexPath) 
    func edit(at indexPath: IndexPath, to newTracker: Tracker, in categoryName: String)
}

final class TrackerStore: NSObject {
    private let managedContext: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let uiScheduleMarshalling = UIScheduleMarshalling()
    weak var delegate: TrackerStoreDelegate?
    
    private lazy var insertedIndexPaths: [IndexPath] = []
    private lazy var deletedIndexPaths: [IndexPath] = []
    private lazy var updatedIndexPaths: [IndexPath] = []
    private lazy var insertedSections = IndexSet()
    private lazy var deletedSections = IndexSet()
    
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.header", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "schedule == '' || schedule CONTAINS[c] %@", delegate?.currentWeekday ?? "")
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedContext,
                                                                  sectionNameKeyPath: #keyPath(TrackerCoreData.category.header),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    private lazy var pinnedTrackersFetchedResultController = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isPin == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.header", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultController.delegate = self
        
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()
    
    override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("Could not convert delegate to AppDelegate")
        }
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    private func createTracker(_ tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: managedContext)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = self.uiColorMarshalling.toHexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = uiScheduleMarshalling.convertToInt(tracker.schedule)
        
        return trackerCoreData
    }
    
    private func getTracker(from trackerCoreData: TrackerCoreData) -> Tracker {
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
                       schedule: uiScheduleMarshalling.convertToWeekday(schedule), 
                       isPin: false)
    }
    
    private func getCategoryCoreData(for categoryName: String) -> TrackerCategoryCoreData? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", categoryName)
        return try? managedContext.fetch(fetchRequest).first
    }
    
    private func togglesToTracker(at indexPath: IndexPath, _ fetchResult: NSFetchedResultsController<TrackerCoreData>) {
        do {
            fetchResult.object(at: indexPath).isPin.toggle()
            try managedContext.save()
        } catch {
            preconditionFailure("Error to save tracker toggles: \(error)")
        }
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            return fetchedResultsController.sections?.count ?? 0
        }
        return (fetchedResultsController.sections?.count ?? 0) + 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
        
        if section == 0 {
            return pinnedTrackers.count
        } else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        var trackerCoreData: TrackerCoreData
        
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            trackerCoreData = fetchedResultsController.object(at: indexPath)
            return getTracker(from: trackerCoreData)
        }
        
        if indexPath.section == 0 {
            trackerCoreData = pinnedTrackersFetchedResultController.object(at: indexPath)
            return getTracker(from: trackerCoreData)
        } else {
            trackerCoreData = fetchedResultsController.object(at: IndexPath(item: indexPath.item, section: indexPath.section - 1))
            return getTracker(from: trackerCoreData)
        }
    }
    
    func name(of section: Int) -> String? {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            return fetchedResultsController.sections?[section].name
        }
        
        if section == 0 {
            return "Закрепленные"
        } else {
            return fetchedResultsController.sections?[section - 1].name
        }
    }
    
    func searchForTracker(by text: String?) {
        if let searchText = text {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", searchText)
        } else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "schedule == '' || schedule CONTAINS[c] %@", delegate?.currentWeekday ?? "")
            
        }
        try? fetchedResultsController.performFetch()
    }
    
    func createTracker(_ tracker: Tracker, in categoryName: String) {
        do {
            let fetchRequest = TrackerCategoryCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "header == %@", categoryName)
            let categoryCoreData = try managedContext.fetch(fetchRequest).first
            let trackerCoreData = try createTracker(tracker)
            trackerCoreData.category = categoryCoreData
            try managedContext.save()
        } catch {
            preconditionFailure("Error create tracker: \(error)")
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        do {
            let trackerCoreData = fetchedResultsController.object(at: indexPath)
            managedContext.delete(trackerCoreData)
            try managedContext.save()
        } catch {
            preconditionFailure("Error create tracker: \(error)")
        }
    }
    
    func toggleTrackerPin(at indexPath: IndexPath) {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            togglesToTracker(at: indexPath, fetchedResultsController)
            return
        }
        
        if indexPath.section == 0 {
            togglesToTracker(at: indexPath, pinnedTrackersFetchedResultController)
        } else {
            let modifiedIndexPath = IndexPath(item: indexPath.item, section: indexPath.section - 1)
            togglesToTracker(at: modifiedIndexPath, fetchedResultsController)
        }
    }
    
    func edit(at indexPath: IndexPath, to newTracker: Tracker, in categoryName: String) {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        trackerCoreData.name = newTracker.name
        trackerCoreData.emoji = newTracker.emoji
        trackerCoreData.isPin = newTracker.isPin
        trackerCoreData.schedule = uiScheduleMarshalling.convertToInt(newTracker.schedule)
        trackerCoreData.colorHex = uiColorMarshalling.toHexString(from: newTracker.color)
        trackerCoreData.category = getCategoryCoreData(for: categoryName)
        
        do {
            try managedContext.save()
        } catch {
            print("Failed to edit tracker")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexPaths: insertedIndexPaths,
            deletedIndexPaths: deletedIndexPaths,
            updatedIndexPaths: updatedIndexPaths,
            insertedSections: insertedSections,
            deletedSections: deletedSections))
        
        insertedIndexPaths = []
        deletedIndexPaths = []
        updatedIndexPaths = []
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexPaths.append(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexPaths.append(indexPath)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                deletedIndexPaths.append(indexPath)
                insertedIndexPaths.append(newIndexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
        default:
            break
        }
    }
}

//
//  TrackerProvider.swift
//  Tracker
//
//  Created by Виктория Щербакова on 31.07.2023.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
    let updatedIndexPaths: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerProviderDelegate: AnyObject {
    var currentWeekday: String { get }
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerProviderProtocol: AnyObject {
    var delegate: TrackerProviderDelegate? { get set }
    var numberOfSections: Int { get }
    
    func numberOfItemsInSection(_ section: Int) -> Int
    func addCategory(_ name: String, with tracker: Tracker)
    func object(at indexPath: IndexPath) -> Tracker?
    func name(of section: Int) -> String?
    func updateTrackerRecord(id: UUID, date: Date)
    func trackerRecordCount(for id: UUID) -> Int
    func isTrackerCompleted(_ id: UUID, with date: Date) -> Bool
    func searchForTracker(by text: String?)
}

final class TrackerProvider: NSObject {
    weak var delegate: TrackerProviderDelegate?
    private let managedObjectContext: NSManagedObjectContext
    private lazy var insertedIndexPaths: [IndexPath] = []
    private lazy var deletedIndexPaths: [IndexPath] = []
    private lazy var updatedIndexPaths: [IndexPath] = []
    private lazy var insertedSections = IndexSet()
    private lazy var deletedSections = IndexSet()
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        return TrackerStore(managedContext: managedObjectContext)
    }()
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = {
        return TrackerCategoryStore(managedContext: managedObjectContext)
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        return TrackerRecordStore(managedContext: managedObjectContext)
    }()
            
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.header", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "schedule == '' || schedule CONTAINS[c] %@", delegate?.currentWeekday ?? "")
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedObjectContext,
                                                                  sectionNameKeyPath: #keyPath(TrackerCoreData.category.header),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("Could not convert delegate to AppDelegate")
        }

        let persistentContainer = appDelegate.persistentContainer
        managedObjectContext = persistentContainer.viewContext
    }
}

// MARK: - TrackerProviderProtocol
extension TrackerProvider: TrackerProviderProtocol {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerStore.getTracker(from: trackerCoreData)
    }
    
    func name(of section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func isTrackerCompleted(_ id: UUID, with date: Date) -> Bool {
        trackerRecordStore.isTrackerCompleted(id, with: date)
    }
    
    func trackerRecordCount(for trackerId: UUID) -> Int {
        trackerRecordStore.getCountRecords(for: trackerId)
    }
    
    func searchForTracker(by text: String?) {
        if let searchText = text {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", searchText)
        } else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "schedule == '' || schedule CONTAINS[c] %@", delegate?.currentWeekday ?? "")

        }
        try? fetchedResultsController.performFetch()
    }
    
    func addCategory(_ name: String, with tracker: Tracker) {
        do {
            let trackerCoreData = try trackerStore.createTracker(tracker)
            try trackerCategoryStore.createCategory(name, with: trackerCoreData)
        } catch {
            print("An error occurred: \(error)")
        }
    }
    
    func updateTrackerRecord(id: UUID, date: Date) {
        guard let trackerCoreData = trackerStore.getTracker(with: id) else { return }
        try? trackerRecordStore.updateRecord(trackerCoreData, date: date)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerProvider: NSFetchedResultsControllerDelegate {
    
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

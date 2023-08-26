//
//  TrackerProvider.swift
//  Tracker
//
//  Created by Виктория Щербакова on 31.07.2023.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidTrackerList
    case decodingErrorInvalidColorHex
}

protocol TrackerProviderProtocol: AnyObject {
    func addCategory(_ name: String, with tracker: Tracker) throws
    func updateTrackerRecord(id: UUID, date: Date)
    
    //    func fetchCategoriesFor(weekday: Int, animating: Bool)
    //    func fetchSearchedCategories(textToSearch: String, weekday: Int)
    //
    //    func fetchRecordsCountForId(_ id: UUID) -> Int
    //    func checkTrackerRecordExist(id: UUID, date: String) -> Bool
    //    func deleteTrackerRecord(id: UUID, date: String) throws
    //
    //    var categories: [TrackerCategory] { get }
    //    var delegate: TrackerDataControllerDelegate? { get set }
}

final class TrackerProvider: NSObject {
    private let managedObjectContext: NSManagedObjectContext
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        return TrackerStore(managedContext: managedObjectContext)
    }()
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = {
        return TrackerCategoryStore(managedContext: managedObjectContext)
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        return TrackerRecordStore(managedContext: managedObjectContext)
    }()
    
    //    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
    //        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
    //        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    //        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
    //                                                                  managedObjectContext: self.persistentContainer.viewContext,
    //                                                                  sectionNameKeyPath: nil,
    //                                                                  cacheName: nil)
    //        fetchedResultsController.delegate = self
    //        try? fetchedResultsController.performFetch()
    //        return fetchedResultsController
    //    }()
    
//    convenience override init() {
//        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
//        try! self.init(trackerStore: TrackerStore(persistentContainer: persistentContainer),
//                       trackerCategoryStore: TrackerCategoryStore(persistentContainer: persistentContainer),
//                       trackerRecordStore: TrackerRecordStore(persistentContainer: persistentContainer),
//                       persistentContainer: persistentContainer)
//    }
    
    override init() {
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        managedObjectContext = persistentContainer.viewContext
    }
    
//    init(trackerStore: TrackerStoreProtocol,
//         trackerCategoryStore: TrackerCategoryStoreProtocol,
//         trackerRecordStore: TrackerRecordStore,
//         persistentContainer: NSPersistentContainer) throws {
//        self.trackerStore = trackerStore
//        self.trackerCategoryStore = trackerCategoryStore
//        self.trackerRecordStore = trackerRecordStore
//        self.persistentContainer = persistentContainer
//
//        super.init()
//    }
}

extension TrackerProvider: TrackerProviderProtocol {
    
    func addCategory(_ name: String, with tracker: Tracker) throws {
        let trackerCoreData = try trackerStore.createTracker(tracker)
        try? trackerCategoryStore.createCategory(name, with: trackerCoreData)
    }
    
    func updateTrackerRecord(id: UUID, date: Date) {
        guard let trackerCoreData = trackerStore.getTracker(with: id) else { return }
        try? trackerRecordStore.updateRecord(trackerCoreData, date: date)
    }
    
}

extension TrackerProvider: NSFetchedResultsControllerDelegate {
}

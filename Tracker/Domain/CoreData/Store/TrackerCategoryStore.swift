//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.04.2023.
//

import CoreData
import UIKit

struct TrackerCategoryStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

protocol TrackerCategoryStoreProtocol {
    var delegate: TrackerCategoryStoreDelegate? { get set }
    var numberOfRows: Int { get }
    var categories: [TrackerCategory] { get }
    func createCategory(_ name: String)
    func object(at indexPath: IndexPath) -> TrackerCategory?
}

final class TrackerCategoryStore: NSObject {
    private let managedContext: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private lazy var insertedIndexPaths: [IndexPath] = []
    private lazy var deletedIndexPaths: [IndexPath] = []
    
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "header", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext) {
        self.managedContext = context
    }
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("Could not convert delegate to AppDelegate")
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    private func getTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory {
        guard let header = trackerCategoryCoreData.header else { preconditionFailure("Failed to load data") }
        return TrackerCategory(header: header, trackersList: [])
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
 
    var categories: [TrackerCategory] {
        fetchedResultsController.fetchedObjects?.map { trackerCategory in
            getTrackerCategory(from: trackerCategory)
        } ?? []
    }
    
    var numberOfRows: Int {
        fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        return getTrackerCategory(from: trackerCategoryCoreData)
    }
    
    func getCategory(at indexPath: IndexPath) -> String? {
        fetchedResultsController.object(at: indexPath).header
    }

    func createCategory(_ name: String) {
        let fetchRequest = fetchedResultsController.fetchRequest
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

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}

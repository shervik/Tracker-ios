//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Виктория Щербакова on 13.10.2023.
//

import Foundation

protocol CategoryListViewControllerDelegate: AnyObject {
    func confirmCategory(with name: String)
}

protocol CategoryListViewModelProtocol: AnyObject {
    var delegate: CategoryListViewControllerDelegate? { get set }
    var trackerCategory: [TrackerCategory] { get }
    var updateHandler: (() -> Void)? { get set }
    var numberOfRows: Int { get }
    var isListCategoryVisible: Bool { get }
    func getName(at indexPath: IndexPath) -> String?
    func createCategory(with categoryName: String)
    func chooseCategory(at indexPath: IndexPath)
}

final class CategoryListViewModel {
    weak var delegate: CategoryListViewControllerDelegate?
    var updateHandler: (() -> Void)?
    private var trackerCategoryStore: TrackerCategoryStoreProtocol
    
    private(set) var trackerCategory: [TrackerCategory] = [] {
        didSet {
            updateHandler?()
        }
    }
    
    init() {
        trackerCategoryStore = TrackerCategoryStore()
        trackerCategoryStore.delegate = self
        didUpdateCategories()
    }
}

extension CategoryListViewModel: CategoryListViewModelProtocol {
    
    func chooseCategory(at indexPath: IndexPath) {
        if let nameCategory = getName(at: indexPath){
            delegate?.confirmCategory(with: nameCategory)
        }
    }
    
    var numberOfRows: Int {
        trackerCategoryStore.numberOfRows
    }
    
    var isListCategoryVisible: Bool {
        trackerCategoryStore.numberOfRows != 0
    }
    
    func getName(at indexPath: IndexPath) -> String? {
        trackerCategoryStore.object(at: indexPath)?.header
    }
    
    func createCategory(with categoryName: String) {
        trackerCategoryStore.createCategory(categoryName)
    }
}

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        trackerCategory = trackerCategoryStore.categories
    }
}

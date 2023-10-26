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
    var categoriesDidChange: (() -> Void)? { get set }
    var isListCategoryVisible: Bool { get }
    func createCategory(with categoryName: String)
    func chooseCategory(at indexPath: IndexPath)
}

final class CategoryListViewModel {
    weak var delegate: CategoryListViewControllerDelegate?
    var categoriesDidChange: (() -> Void)?
    private var trackerCategoryStore: TrackerCategoryStoreProtocol
    
    private(set) var trackerCategory: [TrackerCategory] = [] {
        didSet {
            categoriesDidChange?()
        }
    }
    
    init(trackerCategoryStore: TrackerCategoryStoreProtocol) {
        self.trackerCategoryStore = trackerCategoryStore
        didUpdateCategories()
    }
    
    private func selectCategory(at indexPath: IndexPath) {
        trackerCategoryStore.setSelectedCategory(at: indexPath)
    }
}

extension CategoryListViewModel: CategoryListViewModelProtocol {
 
    func chooseCategory(at indexPath: IndexPath) {
        let nameCategory = trackerCategory[indexPath.row].header
        selectCategory(at: indexPath)
        delegate?.confirmCategory(with: nameCategory)
    }
    
    var isListCategoryVisible: Bool {
        trackerCategory.count != 0
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

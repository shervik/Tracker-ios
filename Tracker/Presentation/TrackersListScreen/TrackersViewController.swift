//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 28.03.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var presenter: TrackersPresenterProtocol?
    private lazy var trackerStore: TrackerStoreProtocol = TrackerStore()
    private lazy var trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    
    private lazy var currentDate = Date().startOfDay
    
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        let addTrackerButton = UIBarButtonItem(image: UIImage(systemName: "plus",
                                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                               style: .plain,
                                               target: self,
                                               action: #selector(addTracker)
        )
        
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.ypBlack,
         NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34)]
        
        return navBar
    }()
    
    private lazy var trackerCollection = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .ypWhite
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collection.register(TrackerListHeader.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: TrackerListHeader.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var searchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Поиск"
        search.searchResultsUpdater = self
        search.searchBar.searchBarStyle = .minimal
        definesPresentationContext = true
        return search
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        datePicker.calendar = calendar
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var errorTitle = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var errorImage = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Error")
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerStore.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite
        title = "Трекеры"
        
        view.addSubview(trackerCollection)
        view.addSubview(navigationBar)
        view.addSubview(errorImage)
        view.addSubview(errorTitle)
        
        changeVisible()
        configureConstraint()
    }
    
    func configure(_ presenter: TrackersPresenterProtocol) {
        self.presenter = presenter
    }
    
    private func changeVisible() {
        updateVisability()
        trackerCollection.reloadData()
    }
    
    private func updateVisability() {
        let isCollectionVisible = trackerStore.numberOfSections != 0
        
        errorImage.isHidden = isCollectionVisible
        errorTitle.isHidden = isCollectionVisible
        trackerCollection.isHidden = !isCollectionVisible
    }
    
    @objc func datePickerChanged(_ datePicker: UIDatePicker) {
        currentDate = datePicker.date.startOfDay
        trackerStore.searchForTracker(by: nil)
        changeVisible()
    }
    
    @objc func addTracker() {
        let vc = UINavigationController(rootViewController: TrackerTypeViewController())
        present(vc, animated: true)
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            errorTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorTitle.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            
            trackerCollection.topAnchor.constraint(equalTo: view.topAnchor),
            trackerCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            datePicker.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            trackerStore.searchForTracker(by: nil)
        } else {
            let searchText = searchController.searchBar.text ?? ""
            trackerStore.searchForTracker(by: searchText)
        }
        changeVisible()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: TrackerListHeader.identifier,
                                                                         for: indexPath) as? TrackerListHeader
        else { return UICollectionReusableView() }
        
        view.titleLabel.text = trackerStore.name(of: indexPath.section)
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { trackerStore.numberOfSections }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier,
                                                            for: indexPath) as? TrackerCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        guard let tracker = trackerStore.object(at: indexPath) else { return UICollectionViewCell() }
        let completedDays = trackerRecordStore.getCountRecords(for: tracker.id)
        let isCompleted = trackerRecordStore.isTrackerCompleted(tracker.id, with: currentDate)
        
        cell.configure(with: tracker,
                       isCompletedToday: isCompleted,
                       at: indexPath,
                       completedDays: completedDays)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let trackersListIsEmpty = trackerStore.numberOfItemsInSection(section) == 0
        return trackersListIsEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let trackersListIsEmpty = trackerStore.numberOfItemsInSection(section) == 0
        return trackersListIsEmpty ? UIEdgeInsets.zero : UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didCompletedTracker(with trackerId: UUID, at indexPath: IndexPath) {
        if currentDate <= Date() {
            let trackerRecord = TrackerRecord(id: trackerId, date: currentDate)
            trackerRecordStore.updateRecord(trackerRecord, date: currentDate)
            trackerCollection.reloadItems(at: [indexPath])
        } else {
            didShowErrorForTracker()
        }
    }
    
    func didUncompletedTracker(with trackerId: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: trackerId, date: currentDate)
        trackerRecordStore.updateRecord(trackerRecord, date: currentDate)
        trackerCollection.reloadItems(at: [indexPath])
    }
    
    func didShowErrorForTracker() {
        SnackbarView.show(frame: view.frame, message: "Нельзя отметить трекер для будущей даты")
    }
}


// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    var currentWeekday: String {
        Calendar.current.component(.weekday, from: currentDate).description
    }
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        trackerCollection.performBatchUpdates {
            trackerCollection.insertSections(update.insertedSections)
            trackerCollection.deleteSections(update.deletedSections)
            trackerCollection.insertItems(at: update.insertedIndexPaths)
            trackerCollection.deleteItems(at: update.deletedIndexPaths)
            trackerCollection.reloadItems(at: update.updatedIndexPaths)
        } completion: { _ in
            if let indexPathToScroll = update.insertedIndexPaths.last {
                self.trackerCollection.scrollToItem(at: indexPathToScroll,
                                                    at: .bottom,
                                                    animated: true)
            }
        }
        changeVisible()
    }
}

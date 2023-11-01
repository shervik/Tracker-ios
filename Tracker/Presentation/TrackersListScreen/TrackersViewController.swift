//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 28.03.2023.
//

import UIKit
import YandexMobileMetrica

final class TrackersViewController: UIViewController {
    private var presenter: TrackersPresenterProtocol?
    private lazy var trackerStore: TrackerStoreProtocol = TrackerStore()
    private lazy var trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    private let analyticsService = AnalyticsService()

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
        search.searchBar.placeholder = L10n.search
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
        datePicker.locale = Locale.current
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var errorTitle = {
        let label = UILabel()
        label.text = L10n.TrackerVC.errorTitle
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
        title = L10n.TrackerVC.title
        trackerStore.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite
        
        view.addSubview(trackerCollection)
        view.addSubview(navigationBar)
        view.addSubview(errorImage)
        view.addSubview(errorTitle)
        
        changeVisible()
        configureConstraint()
        
        analyticsService.report(event: "open", params: ["screen" : "main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen" : "main"])
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
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "add_track"])
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
    
    private func deleteTracker(at indexPath: IndexPath) {
        let alert = UIAlertController(title: L10n.Delete.confirmation, message: nil, preferredStyle: .actionSheet)
        alert.view.backgroundColor = .ypBackground

        let okAction = UIAlertAction(title: L10n.delete, style: .default) { _ in
            self.trackerStore.deleteTracker(at: indexPath)
            self.analyticsService.report(event: "click", params: ["screen" : "main", "item" : "delete"])
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel) { _ in }
        alert.addAction(cancelAction)
            
        self.present(alert, animated: true, completion: nil)
    }
    
    private func pinUnpinActionForTracker(at indexPath: IndexPath) {
        trackerStore.toggleTrackerPin(at: indexPath)
        changeVisible()
    }
    
    private func titleForActionPin(at indexPath: IndexPath) -> String {
        if ((trackerStore.object(at: indexPath)?.isPin) != nil) { L10n.pin } else { L10n.unpin }
    }
    
    private func editTracker(at indexPath: IndexPath) {
        self.analyticsService.report(event: "click", params: ["screen" : "main", "item" : "edit"])
          
        let vc = TrackerEditViewController()
        
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
    
    private func editTracker(at indexPath: IndexPath, newTracker: Tracker, newCategoryName: String) {
        trackerStore.edit(at: indexPath, to: newTracker, in: newCategoryName)
        changeVisible()
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
    
    func collectionView(_ collectionView: UICollectionView, 
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
                
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: self.titleForActionPin(at: indexPath) ) { _ in
                    self.pinUnpinActionForTracker(at: indexPath)
                },
                UIAction(title: L10n.edit) { _ in
                    self.editTracker(at: indexPath)
                },
                UIAction(title: L10n.delete, attributes: .destructive) { _ in
                    self.deleteTracker(at: indexPath)
                }
            ])
        })
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
            analyticsService.report(event: "click", params: ["screen" : "main", "item" : "track"])
            let trackerRecord = TrackerRecord(id: trackerId, date: currentDate)
            trackerRecordStore.updateRecord(trackerRecord, date: currentDate)
            trackerCollection.reloadItems(at: [indexPath])
        } else {
            didShowErrorForTracker()
        }
    }
    
    func didUncompletedTracker(with trackerId: UUID, at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "track"])
        let trackerRecord = TrackerRecord(id: trackerId, date: currentDate)
        trackerRecordStore.updateRecord(trackerRecord, date: currentDate)
        trackerCollection.reloadItems(at: [indexPath])
    }
    
    func didShowErrorForTracker() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "track"])
        SnackbarView.show(frame: view.frame, message: L10n.TrackerVC.errorAlert)
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

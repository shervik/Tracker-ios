//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 28.03.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var presenter: TrackersPresenterProtocol?
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate = Date()
    private var searchText: String = ""
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite
        title = "Трекеры"
        
        view.addSubview(navigationBar)
        view.addSubview(trackerCollection)
        view.addSubview(errorImage)
        view.addSubview(errorTitle)
        configureConstraint()
    }
    
    func configure(_ presenter: TrackersPresenterProtocol) {
        self.presenter = presenter
    }
    
    private func changeVisible() {
        let currentWeekDay = Calendar.current.component(.weekday, from: currentDate)
        
        self.visibleCategories = categories.map { category in
            let filteredTrackers = category.trackersList.filter { tracker in
                guard let weekDay = WeekDay(rawValue: currentWeekDay)
                else { preconditionFailure("Weekday must be in range of 1...7") }
                
                let schedule = tracker.schedule.contains(weekDay)
                let completedTrackers = completedTrackers.contains(.init(id: tracker.id, date: currentDate))
                
                return schedule && !completedTrackers
            }
            return TrackerCategory(header: category.header, trackersList: filteredTrackers)
        }

        updateVisability()
        trackerCollection.reloadData()
    }
    
    private func updateVisability() {
        if visibleCategories.isEmpty || visibleCategories[0].trackersList.isEmpty {
            errorImage.isHidden = false
            errorTitle.isHidden = false
            trackerCollection.isHidden = true
        } else {
            errorImage.isHidden = true
            errorTitle.isHidden = true
            trackerCollection.isHidden = false
        }
    }
    
    @objc func datePickerChanged(_ datePicker: UIDatePicker) {
        currentDate = datePicker.date
        changeVisible()
    }
    
    @objc func addTracker() {
        let vc = UINavigationController(rootViewController: TrackerTypeViewController { [weak self] newTracker in
            guard let self = self else { return }
            
            if self.categories.isEmpty {
                let newCategory = TrackerCategory(header: "Наименование категории", trackersList: [newTracker])
                self.categories = [newCategory]
            } else {
                var trackers = self.categories[0].trackersList
                trackers.append(newTracker)
                let newCategory = TrackerCategory(header: self.categories[0].header, trackersList: trackers)
                self.categories[0] = newCategory
            }
            self.changeVisible()
            
        })
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
        searchText = searchController.searchBar.text ?? ""
        if searchText.isEmpty {
            changeVisible()
        } else {
            visibleCategories = categories.map({ category in
                let filteredTrackers = category.trackersList.filter { tracker in
                    return tracker.name.lowercased().contains(searchText.lowercased())
                }
                return TrackerCategory(header: category.header, trackersList: filteredTrackers)
            })
        }
        updateVisability()
        trackerCollection.reloadData()
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
                
        if !visibleCategories.isEmpty {
            view.titleLabel.text = "\(visibleCategories[indexPath.section].header)"
        }
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return visibleCategories.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackersList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier,
                                                            for: indexPath) as? TrackerCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let tracker = categories[indexPath.section].trackersList[indexPath.row]
        
        cell.trackerTitle.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.cardView.backgroundColor = tracker.color
        cell.addButton.backgroundColor = tracker.color
        
        cell.prepareForReuse()
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
        
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    
    func didDoneTracker(_ cell: TrackerCell) {
        if currentDate <= Date() {
            cell.countDays += 1
            cell.dayLabel.text = "\(cell.countDays) день"
            guard let indexPath = trackerCollection.indexPath(for: cell) else { return }
            
            let trackers = visibleCategories[indexPath.section].trackersList[indexPath.row]
            var todayCompletedTracker = completedTrackers
            todayCompletedTracker.insert(TrackerRecord(id: trackers.id, date: currentDate))
            completedTrackers = todayCompletedTracker
            
            changeVisible()
        }
    }
}

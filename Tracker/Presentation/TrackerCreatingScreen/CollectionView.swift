//
//  CollectionView.swift
//  Tracker
//
//  Created by Виктория Щербакова on 05.04.2023.
//

import UIKit

protocol CollectionViewDelegate: AnyObject {
    func didOpenScreen(_ view: UIViewController)
    func didEnabledCreateButton(textField: UITextField, schedule: Set<WeekDay>)
}

final class CollectionView: NSObject {
    weak var delegate: CollectionViewDelegate?
    private var scheduleVC: ScheduleViewController?
    
    private let collection: UICollectionView
    
    private var listSettingsItem = [String]()
    private var weekDayList: Set<WeekDay> = []
    
    private var category: TrackerCategory = TrackerCategory(header: "Настольные игры",
                                                            trackersList: [])
    
    private var emojiList = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                             "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                             "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private var newTrackerTitle = String()
    private var newTrackerColor: UIColor = .red
    
    init(collection: UICollectionView) {
        self.collection = collection
        super.init()
        
        collection.register(TextFieldCell.self, forCellWithReuseIdentifier: TextFieldCell.identifier)
        collection.register(SettingsListCells.self, forCellWithReuseIdentifier: SettingsListCells.identifier)
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collection.register(HeaderCell.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: HeaderCell.identifier)
        collection.delegate = self
        collection.dataSource = self
        
        collection.reloadData()
    }
    
    func add(items values: [String]) {
        guard !values.isEmpty else { return }
        listSettingsItem = values
    }
    
    func createTracker() -> Tracker {
        return Tracker(id: UUID.init(),
                       name: newTrackerTitle,
                       color: newTrackerColor,
                       emoji: emojiList.randomElement() ?? "",
                       schedule: weekDayList)
    }
}

// MARK: - UITextFieldDelegate
extension CollectionView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        newTrackerTitle = textField.text ?? "default"
    }
}

// MARK: - TextFieldCellDelegate
extension CollectionView: TextFieldCellDelegate {
    func didEnabledCreateButton(textField: UITextField) {
        delegate?.didEnabledCreateButton(textField: textField, schedule: weekDayList)
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return listSettingsItem.count
        case 2:
            return emojiList.count
        default:
            assertionFailure("Unsupported section in numberOfItemsInSection")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return textFieldCell(for: indexPath, collectionView: collectionView)
        case 1:
            return listCell(for: indexPath, collectionView: collectionView)
        case 2:
            return emojiCell(for: indexPath, collectionView: collectionView)
        default:
            assertionFailure("Unsupported section in cellForItemAt")
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: HeaderCell.identifier,
                                                                               for: indexPath) as? HeaderCell
        else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 2: headerCell.headerText.text = "Emoji"
        default:
            assertionFailure("Unsupported header in sectionForItemAt")
        }
        
        return headerCell
    }
    
    private func textFieldCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextFieldCell.identifier,
                                                            for: indexPath) as? TextFieldCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        cell.textInput.delegate = self
        
        return cell
    }
    
    private func listCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: SettingsListCells.identifier,
                                                             for: indexPath) as? SettingsListCells
        else { return UICollectionViewCell() }
        
        cell.titleLabel.text = listSettingsItem[indexPath.row]
        
        let countItems = collectionView.numberOfItems(inSection: indexPath.section) - 1
        if countItems > 0 {
            switch indexPath.row {
            case 0: cell.positionCell = .first
            case countItems: cell.positionCell = .last
            default: cell.positionCell = nil
            }
        } else {
            cell.positionCell = nil
        }
        
        if indexPath.row == 0 {
            cell.subtitleLabel.text = category.header
        } else {
            cell.subtitleLabel.text = weekDayList.map { String($0.cutName) }.joined(separator: ", ")
        }
        
        return cell
    }
    
    private func emojiCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: EmojiCell.identifier,
                                                             for: indexPath) as? EmojiCell
        else { return UICollectionViewCell() }
        
        cell.emojiLabel.text = emojiList[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            scheduleVC = ScheduleViewController()
            scheduleVC?.delegate = self
            delegate?.didOpenScreen(scheduleVC ?? UIViewController())
        }
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CollectionView: ScheduleViewControllerDelegate {
    func didSelectWeekDay(days: Set<WeekDay>) {
        weekDayList = days
        collection.reloadSections(IndexSet(integer: 1))
    }
}

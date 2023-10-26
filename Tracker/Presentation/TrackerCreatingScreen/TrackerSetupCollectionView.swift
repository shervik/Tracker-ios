//
//  TrackerSetupCollectionView.swift
//  Tracker
//
//  Created by Виктория Щербакова on 05.04.2023.
//

import UIKit

protocol CollectionViewDelegate: AnyObject {
    func didOpenScreen(_ view: UIViewController)
    func didEnabledCreateButton(isEnabledCreate: Bool, isEmptyWeekDay: Bool)
}

final class TrackerSetupCollectionView: NSObject {
    weak var delegate: CollectionViewDelegate?
    private var scheduleVC: ScheduleViewController?
    private var categoryVC: CategoryListViewController?
    
    private let collection: UICollectionView
    private let trackerStore: TrackerStoreProtocol
    private var listSettingsItem = [String]()
    private var weekDayList: [WeekDay] = []
    private var newTrackerTitle = String() {
        didSet {
            arrayForSelectedItems["Title"] = newTrackerTitle
        }
    }
    
    private var newTrackerEmoji = String() {
        didSet {
            arrayForSelectedItems["Emoji"] = newTrackerEmoji
        }
    }
    
    private var newTrackerColor = UIColor() {
        didSet {
            arrayForSelectedItems["Color"] = newTrackerColor
        }
    }
    
    private var arrayForSelectedItems: [String : Any] = ["Title": String(), "Emoji": String(), "Color": UIColor.clear] {
        didSet {
            guard let title = arrayForSelectedItems["Title"] as? String,
                  let color = arrayForSelectedItems["Color"] as? UIColor,
                  let emoji = arrayForSelectedItems["Emoji"] as? String else { return }
            
            let hasEmptyValue = color == UIColor.clear || emoji == String() ||
            title == String() || title.count > 38
            
            delegate?.didEnabledCreateButton(isEnabledCreate: !hasEmptyValue, isEmptyWeekDay: weekDayList.isEmpty)
        }
    }
    
    private var categoryName: String = String()
    
    private var emojiList = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                             "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                             "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private var colorList: Array<UIColor> = [.ypTrackerRed, .ypTrackerOrange, .ypTrackerBlue,
                                             .ypTrackerPurple, .ypTrackerGreen, .ypTrackerModerateOrchid,
                                             .ypTrackerFawn, .ypTrackerBlueLilac, .ypTrackerLime,
                                             .ypTrackerDeepPurple, .ypTrackerTomato, .ypTrackerPurplePink,
                                             .ypTrackerLightTurquoise, .ypTrackerCornflowerBlue, .ypTrackerOrchid,
                                             .ypTrackerLightPink, .ypTrackerBlueDegrees, .ypTrackerModerateAspid]
    
    init(collection: UICollectionView) {
        self.collection = collection
        self.trackerStore = TrackerStore()
        super.init()
        
        collection.register(TextFieldCell.self, forCellWithReuseIdentifier: TextFieldCell.identifier)
        collection.register(SettingsListCells.self, forCellWithReuseIdentifier: SettingsListCells.identifier)
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collection.register(HeaderCell.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: HeaderCell.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.allowsMultipleSelection = true
        collection.reloadData()
    }
    
    func add(items values: [String]) {
        guard !values.isEmpty else { return }
        listSettingsItem = values
    }
    
    func createTracker() {
        let newTracker = Tracker(id: UUID.init(),
                name: newTrackerTitle,
                color: newTrackerColor,
                emoji: newTrackerEmoji,
                schedule: Set(weekDayList))
        trackerStore.createTracker(newTracker, in: categoryName)
    }
}

// MARK: - TextFieldCellDelegate
extension TrackerSetupCollectionView: TextFieldCellDelegate {
    func getTitleTrecker(from textField: UITextField) {
        newTrackerTitle = textField.text ?? String()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerSetupCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return listSettingsItem.count
        case 2:
            return emojiList.count
        case 3:
            return colorList.count
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
        case 3:
            return colorCell(for: indexPath, collectionView: collectionView)
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
        case 3: headerCell.headerText.text = "Цвет"
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
            cell.subtitleLabel.text = categoryName
        } else {
            cell.subtitleLabel.text = weekDayList.count == 7 ? "Каждый день" : weekDayList.map {
                String($0.cutName)
            }.joined(separator: ", ")
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
    
    private func colorCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: ColorCell.identifier,
                                                             for: indexPath) as? ColorCell
        else { return UICollectionViewCell() }
        
        cell.colorView.backgroundColor = colorList[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerSetupCollectionView: UICollectionViewDelegate {
    
    func isCollectionFilled() -> Bool {
        for section in 0..<collection.numberOfSections {
            for row in 0..<collection.numberOfItems(inSection: section) {
                let cell = collection.cellForItem(at: IndexPath(row: row, section: section)) as? EmojiCell
                if !(cell?.isSelected ?? false) { return false }
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                categoryVC = CategoryListViewController(delegate: self)
                delegate?.didOpenScreen(categoryVC ?? UIViewController())
            } else if indexPath.row == 1 {
                scheduleVC = ScheduleViewController()
                scheduleVC?.delegate = self
                delegate?.didOpenScreen(scheduleVC ?? UIViewController())
            }
        case 2:
            let emojiCell = cell as? EmojiCell
            newTrackerEmoji = emojiCell?.emojiLabel.text ?? String()
        case 3:
            let colorCell = cell as? ColorCell
            newTrackerColor = colorCell?.colorView.backgroundColor ?? UIColor.clear
        default:
            return
        }
        cell.isSelected = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        switch indexPath.section {
        case 2: newTrackerEmoji = String()
        case 3: newTrackerColor = UIColor.clear
        default: return
        }
        cell.isSelected = false
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({
            $0.section == indexPath.section
        }).forEach({ collectionView.deselectItem(at: $0, animated: false) })
        return true
    }
}

// MARK: - ScheduleViewControllerDelegate
extension TrackerSetupCollectionView: ScheduleViewControllerDelegate {
    func didSelectWeekDay(days: Set<WeekDay>) {
        weekDayList = days.sorted { day1, day2 in
            if day1 == .sunday {
                return false
            }
            if day2 == .sunday {
                return true
            }
            return day1.rawValue < day2.rawValue
        }
        
        collection.reloadSections(IndexSet(integer: 1))
    }
}

extension TrackerSetupCollectionView: CategoryListViewControllerDelegate {
    func confirmCategory(with name: String) {
        categoryName = name
        collection.reloadData()
    }
}

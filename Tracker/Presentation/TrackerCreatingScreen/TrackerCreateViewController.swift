//
//  TrackerCreateViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 31.03.2023.
//

import UIKit

private enum Constants {
    private static let isSmall = UIDevice.current.accessibilityFrame.height < 600
    
    static let topToNavBar: CGFloat = isSmall ? 24 : 16
    static let bottomToSafeArea: CGFloat = isSmall ? 24 : 16
    static let bottomToButton: CGFloat = isSmall ? 24 : 47
    static let topSettingsCollection: CGFloat = 24
    static let bottomSettingsCollection: CGFloat = 32
    static let bottomEmojiCollection: CGFloat = 40
    static let cornerRadius: CGFloat = 16
    static let paddingForSeparator: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    static let paddingForView: CGFloat = 16
    static let buttonFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let heightButtons: CGFloat = 60
    static let heightRowTable: CGFloat = 75
}

final class TrackerCreateViewController: UIViewController {
    
    private var isRegular: Bool
    private lazy var helper = CollectionView(collection: collectionView)
    
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: getCollectionLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var cancelButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor.ypRed, for: .normal)
        button.titleLabel?.font = Constants.buttonFont
        button.layer.cornerRadius = Constants.cornerRadius
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelCreateTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.titleLabel?.font = Constants.buttonFont
        button.layer.cornerRadius = Constants.cornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(successCreatedTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        [cancelButton, createButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(isRegular: Bool) {
        self.isRegular = isRegular
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        helper.delegate = self
        helper.add(items: setSettingList())
        hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite
        
        view.addSubview(collectionView)
        view.addSubview(hStack)
        
        setupConstraint()
    }
    
    @objc private func cancelCreateTracker() {
        dismiss(animated: true)
    }
    
    @objc private func successCreatedTracker() {
        helper.createTracker()
        dismiss(animated: true)
    }
    
    private func hideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    private func setSettingList() -> Array<String> {
        isRegular ? ["Категория", "Расписание"] : ["Категория"]
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topToNavBar),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForView),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForView),
            collectionView.bottomAnchor.constraint(equalTo: hStack.topAnchor, constant: -Constants.bottomToButton),
            
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForView),
            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForView),
            hStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomToSafeArea),
            hStack.heightAnchor.constraint(equalToConstant: Constants.heightButtons),
        ])
    }
}

// MARK: - CollectionViewDelegate
extension TrackerCreateViewController: CollectionViewDelegate {

    func didEnabledCreateButton(isEnabledCreate: Bool, isEmptyWeekDay: Bool) {
        let isNotEmptySchedule = (isRegular && !isEmptyWeekDay) || !isRegular
        
        if isEnabledCreate && isNotEmptySchedule {
            createButton.backgroundColor = .ypBlack
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .ypGray
            createButton.isEnabled = false
        }
    }
    
    func didOpenScreen(_ view: UIViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
}

// MARK: - UICollectionViewCompositionalLayout
extension TrackerCreateViewController {
    private func getCollectionLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) ->
            NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0: return self.getTextFieldLayout()
            case 1: return self.getSettingsListLayout()
            case 2: return self.getEmojiListLayout()
            case 3: return self.getColorListLayout()
            default:
                assertionFailure("Unsupported section in generateLayout")
                return nil
            }
        }
    }
    
    private func getTextFieldLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(75)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: Constants.paddingForView,
                                                        bottom: 0,
                                                        trailing: Constants.paddingForView)
        
        return section
    }
    
    private func getSettingsListLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.heightRowTable)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.topSettingsCollection,
                                                        leading: Constants.paddingForView,
                                                        bottom: Constants.bottomSettingsCollection,
                                                        trailing: Constants.paddingForView)
        
        return section
    }
    
    private func getEmojiListLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0/6.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0/6.0)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item])
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: Constants.paddingForView,
                                                        bottom: Constants.bottomEmojiCollection,
                                                        trailing: Constants.paddingForView)
        
        return section
    }
    
    private func getColorListLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0/6.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0/6.0)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item])
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: Constants.paddingForView,
                                                        bottom: 0,
                                                        trailing: Constants.paddingForView)
        
        return section
    }
}

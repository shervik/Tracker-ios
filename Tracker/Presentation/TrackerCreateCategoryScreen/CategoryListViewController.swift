//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 07.10.2023.
//

import UIKit

private enum Constants {
    private static let isSmall = UIDevice.current.accessibilityFrame.height < 600
    
    static let bottomToSafeArea: CGFloat = isSmall ? 24 : 16
    static let bottomToButton: CGFloat = isSmall ? 24 : 47
    static let cornerRadius: CGFloat = 16
    static let paddingForSeparator: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    static let paddingForView: CGFloat = 16
    static let buttonFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let cellFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
    static let heightButton: CGFloat = 60
    static let heightRowTable: CGFloat = 75
}

protocol CategoryListViewControllerDelegate: AnyObject {
    func confirmCategory(with name: String)
}

final class CategoryListViewController: UIViewController {
    weak var delegate: CategoryListViewControllerDelegate?
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()

    private lazy var tableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrackerCategoryCell")
        tableView.separatorInset = Constants.paddingForSeparator
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var buttonDone = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = Constants.buttonFont
        button.layer.cornerRadius = Constants.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var errorTitle = {
        let label = UILabel()
        label.numberOfLines = 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.28
        label.attributedText = NSMutableAttributedString(string: "Привычки и события можно \n объединить по смыслу", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var errorImage = {
        let imageView = UIImageView(image: UIImage(named: "Error"))
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категория"
        navigationItem.setHidesBackButton(true, animated: false)
        trackerCategoryStore.delegate = self
        updateVisability()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite

        view.addSubview(tableView)
        view.addSubview(buttonDone)
        view.addSubview(errorImage)
        view.addSubview(errorTitle)
        
        setupConstraint()
    }
    
    @objc private func addCategory() {
        let categoryCreateVC = CategoryCreateViewController()
        categoryCreateVC.delegate = self
        navigationController?.pushViewController(categoryCreateVC, animated: true)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonDone.topAnchor, constant: -Constants.bottomToButton),
            
            buttonDone.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomToSafeArea),
            buttonDone.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForView),
            buttonDone.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForView),
            buttonDone.heightAnchor.constraint(equalToConstant: Constants.heightButton),
            
            errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            errorTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorTitle.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
        ])
    }
    
    private func updateVisability() {
        let isListCategoryVisible = trackerCategoryStore.numberOfRows() != 0
        
        errorImage.isHidden = isListCategoryVisible
        errorTitle.isHidden = isListCategoryVisible
        tableView.isHidden = !isListCategoryVisible
        
        tableView.reloadData()

    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        guard let nameOfCategory = trackerCategoryStore.object(at: indexPath)?.header else { return }
        delegate?.confirmCategory(with: nameOfCategory)
        navigationController?.popViewController(animated: true)
    }


    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerCategoryStore.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TrackerCategoryCell")

        cell.selectionStyle = .none
        cell.textLabel?.font = Constants.cellFont
        cell.textLabel?.text = trackerCategoryStore.object(at: indexPath)?.header
        cell.backgroundColor = .ypBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.heightRowTable
    }
}

// MARK: - CategoryCreateViewControllerDelegate
extension CategoryListViewController: CategoryCreateViewControllerDelegate {
    
    func didCreateCategory(with categoryName: String) {
        trackerCategoryStore.createCategory(categoryName)
        updateVisability()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryListViewController: TrackerCategoryStoreDelegate {

    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: update.insertedIndexPaths, with: .automatic)
            tableView.deleteRows(at: update.deletedIndexPaths, with: .automatic)
        } completion: { _ in
            if let indexPathToScroll = update.insertedIndexPaths.last {
                self.tableView.scrollToRow(at: indexPathToScroll,
                                           at: .bottom,
                                           animated: true)
            }
        }
        updateVisability()
    }
}

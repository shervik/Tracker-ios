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
    static let heightButton: CGFloat = 60
    static let heightRowTable: CGFloat = 75
}

final class CategoryListViewController: UIViewController {
    private var viewModel: CategoryListViewModelProtocol?

    private lazy var tableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackerCategoryCell.self, forCellReuseIdentifier: TrackerCategoryCell.identifier)
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
    
    init(delegate: CategoryListViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        let store = TrackerCategoryStore()
        viewModel = CategoryListViewModel(trackerCategoryStore: store)
        store.delegate = self.viewModel as? TrackerCategoryStoreDelegate
        viewModel?.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категория"
        navigationItem.setHidesBackButton(true, animated: false)
        bind()
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
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.categoriesDidChange = { [weak self] in
            self?.updateVisability()
        }
    }
    
    @objc private func addCategory() {
        let categoryCreateVC = CategoryCreateViewController()
        categoryCreateVC.categoryCallback = { [weak self] categoryName in
            self?.viewModel?.createCategory(with: categoryName)
            self?.updateVisability()
        }
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
        guard let isListCategoryVisible = viewModel?.isListCategoryVisible else { return }
        
        errorImage.isHidden = isListCategoryVisible
        errorTitle.isHidden = isListCategoryVisible
        tableView.isHidden = !isListCategoryVisible
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.chooseCategory(at: indexPath)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.trackerCategory.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCategoryCell.identifier,
                                                       for: indexPath) as? TrackerCategoryCell,
              let category = viewModel?.trackerCategory[indexPath.row]
        else { return UITableViewCell() }

        cell.nameCategory.text = category.header
        cell.isSelectedState = category.isSelected
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.heightRowTable
    }
}

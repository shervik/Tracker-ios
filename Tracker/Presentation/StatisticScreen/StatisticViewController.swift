//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 28.03.2023.
//

import UIKit

final class StatisticViewController: UIViewController {
    private var presenter: StatisticPresenterProtocol?
    private lazy var trackerStore: TrackerStoreProtocol = TrackerStore()
    private lazy var trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.text = L10n.StaticticVC.title
        label.textAlignment = .left
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statisticTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypWhite
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var errorTitle = {
        let label = UILabel()
        label.text = L10n.StaticticVC.errorTitle
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var errorImage = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatisticError")
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
        
        view.addSubview(titleLabel)
        view.addSubview(statisticTableView)
        view.addSubview(errorImage)
        view.addSubview(errorTitle)
        
        configureConstraint()
        
        updateVisability()
        statisticTableView.reloadData()
    }
    
    func configure(_ presenter: StatisticPresenterProtocol) {
        self.presenter = presenter
    }
    
    private func updateVisability() {
        let isTableVisible = trackerRecordStore.allCountRecord != 0
        
        errorImage.isHidden = isTableVisible
        errorTitle.isHidden = isTableVisible
        statisticTableView.isHidden = !isTableVisible
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            
            errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            errorTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorTitle.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            
            statisticTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 65),
            statisticTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statisticTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                    
        ])
    }
}

extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerRecordStore.allCountRecord != 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.identifier,
                                                       for: indexPath) as? StatisticsCell
        else { return UITableViewCell() }
        
        cell.titleLabel.text = L10n.StaticticVC.titleCell
        cell.valueLabel.text = String(trackerRecordStore.allCountRecord)
        return cell
    }
}

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

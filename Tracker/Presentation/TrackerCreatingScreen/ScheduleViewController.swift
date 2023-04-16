//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 31.03.2023.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectWeekDay(days: Set<WeekDay>)
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    
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
    
    private let daysOfWeek = WeekDay.allCases
    private var selectDays: Set<WeekDay> = []
    
    private lazy var tableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = Constants.paddingForSeparator
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var buttonDone = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor.ypWhite, for: .normal)
        button.titleLabel?.font = Constants.buttonFont
        button.layer.cornerRadius = Constants.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.addTarget(self, action: #selector(confirmSchedule), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite
        
        view.addSubview(tableView)
        view.addSubview(buttonDone)
        
        setupConstraint()
    }
    
    @objc private func confirmSchedule() {
        navigationController?.popViewController(animated: true)
        delegate?.didSelectWeekDay(days: selectDays)
    }
    
    @objc func switchChanged(_ sender : UISwitch){
        if sender.isOn {
            selectDays.insert(daysOfWeek[sender.tag])
        }
        
        if (!selectDays.isEmpty && !sender.isOn) {
            selectDays = selectDays.filter() {$0 != daysOfWeek[sender.tag] }
        }
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
        ])
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let switchView = UISwitch()
        switchView.setOn(false, animated: true)
        switchView.onTintColor = .ypBlue
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        cell.selectionStyle = .none
        cell.textLabel?.font = Constants.cellFont
        cell.textLabel?.text = daysOfWeek[indexPath.row].fullName
        cell.backgroundColor = .ypBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.heightRowTable
    }
}

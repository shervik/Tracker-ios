//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 30.03.2023.
//

import UIKit


final class TrackerTypeViewController: UIViewController {
    private var handler: (Tracker) -> Void
    
    private lazy var addHabitButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(createHabit), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var addEventButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(handler: @escaping (Tracker) -> Void) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание трекера"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor = .ypWhite

        view.addSubview(addHabitButton)
        view.addSubview(addEventButton)
        setupConstraint()
    }

    @objc private func createHabit() {
        let vc = TrackerCreateViewController(isRegular: true, handler: handler)
        vc.title = "Новая привычка"
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func createEvent() {
        let vc = TrackerCreateViewController(isRegular: false, handler: handler)
        vc.title = "Новое нерегулярное событие"
        navigationController?.pushViewController(vc, animated: true)
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            addHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),

            addEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addEventButton.topAnchor.constraint(equalTo: addHabitButton.bottomAnchor, constant: 16),
            addEventButton.heightAnchor.constraint(equalToConstant: 60)

        ])
    }
}

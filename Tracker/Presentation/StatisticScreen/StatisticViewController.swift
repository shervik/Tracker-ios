//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 28.03.2023.
//

import UIKit

final class StatisticViewController: UIViewController {
    private var presenter: StatisticPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite
    }
    
    func configure(_ presenter: StatisticPresenterProtocol) {
        self.presenter = presenter
    }

}


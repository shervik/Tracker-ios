//
//  TabBarController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 28.03.2023.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let separator = Separator()
        tabBar.addSubview(separator)
        NSLayoutConstraint.activate(separator.layoutConstraints(for: tabBar))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers()
    }

    private func setViewControllers() {
        let trackerVC = TrackersViewController()
        let trackersPresenter = TrackersPresenter()
        trackerVC.configure(trackersPresenter)

        let statisticVC = StatisticViewController()
        let statisticPresenter = StatisticPresenter()
        statisticVC.configure(statisticPresenter)
        

        let iconTrackers = UITabBarItem(title: "Трекеры",
                                        image: UIImage(systemName: "record.circle.fill"),
                                        tag: 0
        )
        
        let iconStatistic = UITabBarItem(title: "Статистика",
                                         image: UIImage(systemName: "hare.fill"),
                                         tag: 1
        )
        trackerVC.tabBarItem = iconTrackers
        statisticVC.tabBarItem = iconStatistic
        
        self.viewControllers = [UINavigationController(rootViewController: trackerVC), statisticVC]
    }
}

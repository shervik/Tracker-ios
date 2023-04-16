//
//  Separator.swift
//  Tracker
//
//  Created by Виктория Щербакова on 30.03.2023.
//

import UIKit

class Separator: UIView {

    private let height: CGFloat = 0.5

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGray3
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func layoutConstraints(for tabBar: UITabBar) -> [NSLayoutConstraint] {
        [
            widthAnchor.constraint(equalTo: tabBar.widthAnchor),
            heightAnchor.constraint(equalToConstant: height),
            centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            topAnchor.constraint(equalTo: tabBar.topAnchor)
        ]
    }
    
    func layoutConstraints(for view: UIView, padding: CGFloat) -> [NSLayoutConstraint] {
        [
            heightAnchor.constraint(equalToConstant: height),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
    }
}

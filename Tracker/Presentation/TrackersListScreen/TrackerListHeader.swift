//
//  TrackerListHeader.swift
//  Tracker
//
//  Created by Виктория Щербакова on 09.03.2023.
//

import UIKit

final class TrackerListHeader: UICollectionReusableView {
    static let identifier = "TrackerListHeader"
    lazy var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
    
        titleLabel.font = .boldSystemFont(ofSize: 19)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

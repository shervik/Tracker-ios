//
//  TrackerCategoryCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 22.10.2023.
//

import UIKit

final class TrackerCategoryCell: UITableViewCell {
    static let identifier = "TrackerCategoryCell"

    var isSelectedState: Bool = false {
            didSet {
                accessoryType = isSelectedState ? .checkmark : .none
            }
        }
    
    lazy var nameCategory = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameCategory)
        selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = .ypBackground
        self.backgroundView = backgroundView
        
        nameCategory.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameCategory.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameCategory.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameCategory.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

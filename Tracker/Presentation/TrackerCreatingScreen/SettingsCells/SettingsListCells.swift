//
//  SettingsListCells.swift
//  Tracker
//
//  Created by Виктория Щербакова on 03.04.2023.
//

import UIKit

enum Position {
    case first, last
}

private enum Constants {
    static let cornerRadius: CGFloat = 16
    static let cellFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
    static let paddings: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    static let heightRowTable: CGFloat = 75
}

final class SettingsListCells: UICollectionViewCell {
    static let identifier = "SettingsListCells"
    
    var positionCell: Position? {
        didSet {
            updateCell()
        }
    }
    
    private lazy var separator = Separator()

    private lazy var hStack = {
        let stack = UIStackView()
        stack.axis = .horizontal
        [vStack, disclosureIndicator].forEach { view in
            stack.addArrangedSubview(view)
        }
        stack.backgroundColor = .ypBackground
        stack.layer.cornerRadius = Constants.cornerRadius
        stack.layer.masksToBounds = true
        stack.layoutMargins = Constants.paddings
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var vStack = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        [titleLabel, subtitleLabel].forEach { view in
            stack.addArrangedSubview(view)
        }
        return stack
    }()

    lazy var titleLabel = {
        let label = UILabel()
        label.font = Constants.cellFont
        return label
    }()

    lazy var subtitleLabel = {
        let label = UILabel()
        label.font = Constants.cellFont
        label.textColor = .ypGray
        return label
    }()

    private lazy var disclosureIndicator = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right",
                                  withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        imageView.contentMode = .right
        imageView.tintColor = .ypGray
        return imageView
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(hStack)
        contentView.addSubview(separator)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate(separator.layoutConstraints(for: contentView, padding: 16))
    }
    
    private func updateCell() {
        switch positionCell {
        case .first:
            hStack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .last:
            hStack.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separator.isHidden = true
        default:
            hStack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner,
                                          .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            separator.isHidden = true
        }
    }
}

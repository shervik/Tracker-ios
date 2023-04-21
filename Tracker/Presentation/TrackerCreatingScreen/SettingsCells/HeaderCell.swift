//
//  HeaderCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 05.04.2023.
//

import UIKit

final class HeaderCell: UICollectionViewCell {
    static let identifier = "HeaderCell"
    
    lazy var headerText = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 18))
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(headerText)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

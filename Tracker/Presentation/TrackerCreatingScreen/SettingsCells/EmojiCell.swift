//
//  EmojiCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 04.04.2023.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let identifier = "EmojiCell"
    
    lazy var emojiLabel = {
        let label = UILabel(frame: outlineView.bounds.insetBy(dx: 6, dy: 6))
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    lazy var outlineView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isSelected {
            outlineView.backgroundColor = .ypLightGray
        } else {
            outlineView.backgroundColor = .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(outlineView)
        outlineView.addSubview(emojiLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

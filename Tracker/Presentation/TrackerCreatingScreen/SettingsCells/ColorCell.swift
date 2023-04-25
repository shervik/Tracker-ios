//
//  ColorCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 21.04.2023.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    lazy var colorView = {
        let view = UIView(frame: outlineView.bounds.insetBy(dx: 6, dy: 6))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var outlineView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .white.withAlphaComponent(0)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isSelected {
            outlineView.layer.borderWidth = 3.0
            outlineView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
        } else {
            outlineView.layer.borderWidth = 0.0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(outlineView)
        outlineView.addSubview(colorView)
    }
}

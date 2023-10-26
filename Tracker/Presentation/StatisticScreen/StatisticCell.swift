//
//  StatisticCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.10.2023.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    static let identifier = "StatisticsCell"
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypWhite
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        [valueLabel, titleLabel].forEach { view.addSubview($0) }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellView)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -12)
        ])
    }
}

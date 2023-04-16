//
//  TrackerCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 29.03.2023.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didDoneTracker(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    var countDays: Int = 0

    private lazy var subview = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.addSubview(dayLabel)
        view.addSubview(addButton)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var cardView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.addSubview(trackerTitle)
        view.addSubview(emojiInCircle)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var dayLabel = {
        let label = UILabel()
        label.text = "\(countDays) день"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var addButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark"), for: .selected)
        button.tintColor = .ypWhite
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTabButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var trackerTitle = {
        let title = UILabel()
        title.text = "Кошка заслонила камеру на созвоне"
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.font = .systemFont(ofSize: 12, weight: .medium)
        title.textColor = .ypWhite
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    private lazy var emojiInCircle = {
        let circleView = UIView()
        circleView.backgroundColor = UIColor.ypWhite.withAlphaComponent(0.3)
        circleView.layer.masksToBounds = true
        circleView.addSubview(emojiLabel)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        return circleView
    }()
    
    lazy var emojiLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        emojiInCircle.layer.cornerRadius = emojiInCircle.frame.size.width/2
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        contentView.addSubview(subview)
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func didTabButton(_ sender: UIButton) {
//        countDays += 1
//        dayLabel.text = "\(countDays) день"

        delegate?.didDoneTracker(self)
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            trackerTitle.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            trackerTitle.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerTitle.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            emojiInCircle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiInCircle.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiInCircle.widthAnchor.constraint(equalToConstant: 32),
            emojiInCircle.heightAnchor.constraint(equalTo: emojiInCircle.widthAnchor, multiplier: 1),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiInCircle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiInCircle.centerYAnchor),
            
            subview.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            subview.heightAnchor.constraint(equalToConstant: 58),

            dayLabel.centerYAnchor.constraint(equalTo: subview.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 12),

            addButton.centerYAnchor.constraint(equalTo: subview.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor, multiplier: 1),
        ])
    }
}

//
//  TrackerCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 29.03.2023.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 16
    static let cellFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
    static let heightCard: CGFloat = 90
    static let paddings: CGFloat = 12
}

protocol TrackerCellDelegate: AnyObject {
    func didCompletedTracker(with trackerId: UUID, at indexPath: IndexPath)
    func didUncompletedTracker(with trackerId: UUID, at indexPath: IndexPath)
    func didShowErrorForTracker()
}

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    private var isCompletedToday = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    weak var delegate: TrackerCellDelegate?
    
    private lazy var subview = {
        let view = UIView()
        view.addSubview(dayLabel)
        view.addSubview(addButton)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var cardView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        view.addSubview(trackerTitle)
        view.addSubview(emojiInCircle)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayLabel = {
        let label = UILabel()
        label.text = "0 дней"
        label.font = Constants.cellFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var addButton = {
        let button = UIButton()
        button.tintColor = .ypWhite
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTabButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var trackerTitle = {
        let title = UILabel()
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.font = Constants.cellFont
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
    
    func configure(with tracker: Tracker,
                   isCompletedToday: Bool,
                   at indexPath: IndexPath,
                   completedDays: Int) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        trackerTitle.text = tracker.name
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        addButton.backgroundColor = tracker.color
        addButton.alpha = isCompletedToday ? 0.3 : 1
        let image = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        addButton.setImage(image, for: .normal)
        dayLabel.text = "\(completedDays) день"
    }
    
    @objc private func didTabButton() {
        guard let trackerId = trackerId, let indexPath = indexPath else { return }
        
        if isCompletedToday {
            delegate?.didUncompletedTracker(with: trackerId, at: indexPath)
        } else {
            delegate?.didCompletedTracker(with: trackerId, at: indexPath)
        }
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: Constants.heightCard),
            
            trackerTitle.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Constants.paddings),
            trackerTitle.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.paddings),
            trackerTitle.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.paddings),
            
            emojiInCircle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Constants.paddings),
            emojiInCircle.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.paddings),
            emojiInCircle.widthAnchor.constraint(equalToConstant: 32),
            emojiInCircle.heightAnchor.constraint(equalTo: emojiInCircle.widthAnchor, multiplier: 1),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiInCircle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiInCircle.centerYAnchor),
            
            subview.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            subview.heightAnchor.constraint(equalToConstant: 58),
            
            dayLabel.centerYAnchor.constraint(equalTo: subview.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: Constants.paddings),
            
            addButton.centerYAnchor.constraint(equalTo: subview.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -Constants.paddings),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor, multiplier: 1),
        ])
    }
}

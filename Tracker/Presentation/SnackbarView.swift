//
//  SnackbarView.swift
//  Tracker
//
//  Created by Виктория Щербакова on 20.04.2023.
//

import UIKit

final class SnackbarView: UIView {
    
    lazy var messageLabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        
        backgroundColor = .ypRed
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func show(frame: CGRect,
                     message: String,
                     duration: TimeInterval = 1.0) {
        
        let width: CGFloat = frame.width - 60
        let height: CGFloat = 60
        let x = (frame.width / 2) - (width / 2)
        let y = (frame.height / 9) - (height / 2)
        
        let snackbar = SnackbarView(frame: CGRect(x: x, y: y, width: width, height: height))
        
        snackbar.messageLabel.text = message
        
        guard let window = UIApplication.shared.windows.first else { return }
        window.addSubview(snackbar)
        
        
        snackbar.frame.origin.y -= snackbar.frame.size.height
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            snackbar.frame.origin.y += height
        }) { (completed) in
            UIView.animate(withDuration: 0.5, delay: duration, options: [], animations: {
                snackbar.frame.origin.y -= height
                snackbar.alpha = 0
            }, completion: { finished in
                snackbar.removeFromSuperview()
            })
        }
    }
}

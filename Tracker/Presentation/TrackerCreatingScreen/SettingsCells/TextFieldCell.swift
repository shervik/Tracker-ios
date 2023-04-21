//
//  TextFieldCell.swift
//  Tracker
//
//  Created by Виктория Щербакова on 03.04.2023.
//

import UIKit

protocol TextFieldCellDelegate: AnyObject {
    func didEnabledCreateButton(textField: UITextField)
}

final class TextFieldCell: UICollectionViewCell {
    static let identifier = "TextFieldCell"
    weak var delegate: TextFieldCellDelegate?
    
    lazy var textInput = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.placeholder = "Введите название трекера"
        textField.indent(size: 16)
        textField.becomeFirstResponder()
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .ypBackground
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEditingEvents)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var errorTitle = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textInput)
        contentView.addSubview(errorTitle)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        let maxCharacters = 38
        if let text = sender.text, text.count > maxCharacters {
            errorTitle.text = "Ограничение \(maxCharacters) символов"
            errorTitle.isHidden = false
        } else {
            errorTitle.isHidden = true
        }
        delegate?.didEnabledCreateButton(textField: sender)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            textInput.topAnchor.constraint(equalTo: contentView.topAnchor),
            textInput.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textInput.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textInput.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            errorTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorTitle.topAnchor.constraint(equalTo: textInput.bottomAnchor),
        ])
    }
}

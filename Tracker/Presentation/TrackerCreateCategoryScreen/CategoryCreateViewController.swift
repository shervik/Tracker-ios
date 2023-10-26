//
//  CategoryCreateViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 11.10.2023.
//

import UIKit

typealias CategoryCallback = (String) -> Void

private enum Constants {
    private static let isSmall = UIDevice.current.accessibilityFrame.height < 600
    
    static let topToSafeArea: CGFloat = 24
    static let bottomToSafeArea: CGFloat = isSmall ? 24 : 16
    static let cornerRadius: CGFloat = 16
    static let paddingForView: CGFloat = 16
    static let buttonFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let heightButton: CGFloat = 60
    static let heightInput: CGFloat = 75
}

final class CategoryCreateViewController: UIViewController {
    var categoryCallback: CategoryCallback?
    private var categoryName: String = String()

    lazy var textInput = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.placeholder = "Введите название категории"
        textField.indent(size: 16)
        textField.becomeFirstResponder()
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .ypBackground
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEditingEvents)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.resignFirstResponder()
        return textField
    }()
    
    private lazy var buttonDone = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = Constants.buttonFont
        button.layer.cornerRadius = Constants.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(createCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая категория"
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypWhite

        view.addSubview(textInput)
        view.addSubview(buttonDone)
        
        setupConstraint()
    }
    
    @objc private func createCategory() {
        categoryCallback?(categoryName)
        navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            textInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topToSafeArea),
            textInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.paddingForView),
            textInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.paddingForView),
            textInput.heightAnchor.constraint(equalToConstant: Constants.heightInput),
            
            buttonDone.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomToSafeArea),
            buttonDone.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForView),
            buttonDone.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForView),
            buttonDone.heightAnchor.constraint(equalToConstant: Constants.heightButton),
        ])
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        if !text.isEmpty {
            buttonDone.backgroundColor = .ypBlack
            buttonDone.isEnabled = true
            categoryName = text
        } else {
            buttonDone.backgroundColor = .ypGray
            buttonDone.isEnabled = false
        }
    }
}



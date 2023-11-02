//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 22.10.2023.
//

import UIKit

private enum Constants {
    static let paddingForButton: CGFloat = 20
    static let cornerRadius: CGFloat = 16
    static let labelFont: UIFont = .systemFont(ofSize: 32, weight: .bold)
    static let buttonFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let heightButton: CGFloat = 60
    static let paddingForLabel: CGFloat = 16
    static let spacing: CGFloat = 50
}

final class OnboardingPageViewController: UIViewController {
    private var onboardingText: String = ""
    private var imageName: String = ""
    
    private lazy var onboardingImage: UIImageView = {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: imageName)
        return imageView
    }()
    
    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.text = onboardingText
        label.textColor = .black
        label.font = Constants.labelFont
        label.textAlignment = .center
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.Onboarding.button, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = Constants.cornerRadius
        button.titleLabel?.font = Constants.buttonFont
        button.addTarget(self, action: #selector(navigateToTabBarController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(onboardingText: String, imageName: String) {
        super.init(nibName: nil, bundle: nil)
        self.onboardingText = onboardingText
        self.imageName = imageName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(onboardingImage)
        view.addSubview(onboardingLabel)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForLabel),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForLabel),
            onboardingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForButton),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForButton),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.heightButton),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.spacing)
        ])
    }
    
    @objc private func navigateToTabBarController() {
        let vc = TabBarController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
                window.rootViewController = vc
            }
        }
    }
}

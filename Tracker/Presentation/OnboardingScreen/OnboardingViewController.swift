//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.09.2023.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 16
    static let labelFont: UIFont = .systemFont(ofSize: 32, weight: .bold)
    static let buttonFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let heightButton: CGFloat = 60
    static let paddingForLabel: CGFloat = 16
    static let paddingForContainer: CGFloat = 20
    static let paddingBottomForContainer: CGFloat = 50
    static let spacing: CGFloat = 24
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
        label.textColor = .ypBlack
        label.font = Constants.labelFont
        label.textAlignment = .center
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        NSLayoutConstraint.activate([
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForLabel),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForLabel),
            onboardingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

final class OnboardingViewController: UIPageViewController {
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = Constants.cornerRadius
        button.titleLabel?.font = Constants.buttonFont
        button.addTarget(self, action: #selector(navigateToTabBarController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.addSubview(pageControl)
        containerView.addSubview(button)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    private lazy var pages: [UIViewController] = {
        let redOnboarding = OnboardingPageViewController(onboardingText: "Отслеживайте только то, что хотите",
                                                         imageName: "Onboarding1")
        
        let blueOnboarding = OnboardingPageViewController(onboardingText: "Даже если это не литры воды и йога",
                                                          imageName: "Onboarding2")
        
        
        return [redOnboarding, blueOnboarding]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(containerView)

        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.paddingBottomForContainer),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingForContainer),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingForContainer),
            
            pageControl.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    
            button.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: Constants.spacing),
            button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            button.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: Constants.heightButton)
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

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return pages.last }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

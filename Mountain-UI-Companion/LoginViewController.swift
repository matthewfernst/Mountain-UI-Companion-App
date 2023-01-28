//
//  SignInViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/26/23.
//
import AuthenticationServices
import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet var appLabel: UILabel!
    @IBOutlet var learnMoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .signBackgroundLavendar
        self.appLabel.clipsToBounds = true
        self.appLabel.layer.cornerRadius = 10
        self.appLabel.layer.borderWidth = 1.5
        self.appLabel.layer.borderColor = UIColor.black.cgColor
        self.learnMoreButton.addTarget(self, action: #selector(showMountainUIDisplayPage), for: .touchUpInside)
        
        setupProviderLoginView()
        
    }
    
    @objc func showMountainUIDisplayPage() {
        if let url = URL(string: Constants.mountainUIDisplayGitub) {
            UIApplication.shared.open(url)
        }
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.view.addSubview(authorizationButton)

        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorizationButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            authorizationButton.centerYAnchor.constraint(equalTo: self.appLabel.bottomAnchor, constant: 50),
            authorizationButton.widthAnchor.constraint(equalToConstant: 162),
            authorizationButton.heightAnchor.constraint(equalToConstant: 37)
        ])

    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController") {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true)
        }
    }

}

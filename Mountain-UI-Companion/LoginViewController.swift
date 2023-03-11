//
//  SignInViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/26/23.
//
import AuthenticationServices
import UIKit

import GoogleSignIn


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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        preformExistingAccountSetupFlows()
    }
    
    @objc func showMountainUIDisplayPage() {
        if let url = URL(string: Constants.mountainUIDisplayGitub) {
            UIApplication.shared.open(url)
        }
    }
    
    func setupProviderLoginView() {
        setupSignInWithAppleButton()
        setupSignInWithGoogleButton()
    }
    
    // MARK: Apple Sign In
    func setupSignInWithAppleButton() {
        let signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        signInWithAppleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithAppleButton)
        
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithAppleButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            signInWithAppleButton.centerYAnchor.constraint(equalTo: self.appLabel.bottomAnchor, constant: 50),
            signInWithAppleButton.widthAnchor.constraint(equalToConstant: 162),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 37)
        ])
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    func preformExistingAccountSetupFlows() {
        // Prepare the request for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with given requests.
        let controller = ASAuthorizationController(authorizationRequests: requests)
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    // MARK: Google Sign In
    func setupSignInWithGoogleButton() {
        let signInWithGoogleButton = GIDSignInButton()
        signInWithGoogleButton.addTarget(self, action: #selector(handleAuthorizationGoogleButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithGoogleButton)
        
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithGoogleButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            signInWithGoogleButton.centerYAnchor.constraint(equalTo: self.appLabel.bottomAnchor, constant: 95),
            signInWithGoogleButton.widthAnchor.constraint(equalToConstant: 165),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 37)
        ])
    }
    
    @objc func handleAuthorizationGoogleButtonPress() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }

            // If sign in succeeded, display the app's main content View.
//            print(signInResult?.user.profile?.name)
          }
    }
    
    @objc func goToMainApp() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController") {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true)
        }
    }
    
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let identityToken = appleIdCredential.identityToken
            let authCode = appleIdCredential.authorizationCode
            let realUserStatus = appleIdCredential.realUserStatus
            
            // Create an account in your system
            
            goToMainApp()
            break
        
        case let passwordCredential as ASPasswordCredential:
            // Sign in using exisiting iCloud Keychain credential.
            // For the purpose of this demo app, show alert
            break
        default:
            Swift.debugPrint("Not ready yet")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

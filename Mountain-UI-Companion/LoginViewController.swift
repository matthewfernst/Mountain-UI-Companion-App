//
//  SignInViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/26/23.
//
import AuthenticationServices
import UIKit

import Amplify
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin


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
        
        Task {
//          await signUp(username: "matthewfernst", password: "MountainUI@96", email: "matthew.f.ernst@gmail.com")
            await confirmSignUp(for: "matthewfernst", with: "942663")
        }
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController") {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true)
        }
    }
    
    func signUp(username: String, password: String, email: String) async {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: username,
                password: password,
                options: options
            )
            if case let .confirmUser(deliveryDetails, _, userId) = signUpResult.nextStep {
                print("Delivery details \(String(describing: deliveryDetails)) for userId: \(String(describing: userId))")
            } else {
                print("SignUp Complete")
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) async {
        do {
            let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(
                for: username,
                confirmationCode: confirmationCode
            )
            print("Confirm sign up result completed: \(confirmSignUpResult.isSignUpComplete)")
        } catch let error as AuthError {
            print("An error occurred while confirming sign up \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func signIn(username: String, password: String) async {
        do {
            let signInResult = try await Amplify.Auth.signIn(
                username: username,
                password: password
            )
            if signInResult.isSignedIn {
                print("Sign in succeeded")
            }
        } catch let error as AuthError {
            print("Sign in failed \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

}

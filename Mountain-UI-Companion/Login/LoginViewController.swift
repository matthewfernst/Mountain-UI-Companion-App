//
//  SignInViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/26/23.
//
import AuthenticationServices
import AWSClientRuntime
import AWSDynamoDB
import ClientRuntime
import GoogleSignIn
import UIKit
import OSLog

class LoginViewController: UIViewController {
    @IBOutlet var appLabel: UILabel!
    @IBOutlet var learnMoreButton: UIButton!
    
    //    public static var userProfile: Profile!
    
    var profileViewModel = ProfileViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .signBackgroundLavendar
        self.appLabel.clipsToBounds = true
        self.appLabel.layer.borderColor = UIColor.black.cgColor
        self.learnMoreButton.addTarget(self, action: #selector(showMountainUIDisplayPage), for: .touchUpInside)
        
        setupSignInWithAppleButton()
        setupSignInWithGoogleButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        performExistingAccountSetupFlows()
    }
    
    @objc func showMountainUIDisplayPage() {
        if let url = URL(string: Constants.mountainUIDisplayGitub) {
            UIApplication.shared.open(url)
        }
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
            signInWithAppleButton.widthAnchor.constraint(equalToConstant: 250),
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
    
    func performExistingAccountSetupFlows() {
        // Prepare the request for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        // Need to store password for this to work
                        // https://developer.apple.com/forums/thread/131624
                        //                        ASAuthorizationPasswordProvider().createRequest()
        ]
        
        // Create an authorization controller with given requests.
        let controller = ASAuthorizationController(authorizationRequests: requests)
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    // MARK: Google Sign In
    func setupSignInWithGoogleButton() {
        let signInWithGoogleButton = getSignInWithGoogleButton()
        
        signInWithGoogleButton.addTarget(self, action: #selector(handleAuthorizationGoogleButtonPress), for: .touchUpInside)
        self.view.addSubview(signInWithGoogleButton)
        
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInWithGoogleButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            signInWithGoogleButton.centerYAnchor.constraint(equalTo: self.appLabel.bottomAnchor, constant: 95),
            signInWithGoogleButton.widthAnchor.constraint(equalToConstant: 250),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 37)
        ])
    }
    
    @objc func handleAuthorizationGoogleButtonPress() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] signInResult, error in
            guard error == nil else { return }
            guard let profile = signInResult?.user.profile else { return }
            
            Task {
                await handleSignIn(userInfo: UserProfileInfo(name: profile.name,
                                                             email: profile.email,
                                                             profilePictureURL: profile.imageURL(withDimension: 320)!))
                // TODO: Change to ProfileViewModel
                let defaults = UserDefaults.standard
                defaults.set(profile.email, forKey: "email")
                
                self.goToMainApp()
            }
        }
    }
    
    // MARK: Helper functions for Login
    func setCurrentUser(userInfo: UserProfileInfo) {
        Profile.createProfile(name: userInfo.name, email: userInfo.email, profilePictureURL: userInfo.profilePictureURL) { profile in
            self.profileViewModel.updateProfile(newProfile: profile)
        }
    }
    
    func loginUser(userInfo: UserProfileInfo) {
        Logger.userInfo.info("Existing user found.")
        setCurrentUser(userInfo: userInfo)
    }
    
    func createNewUser(userInfo: UserProfileInfo) async {
        Logger.userInfo.info("User does not exist. Creating User.")
        
        setCurrentUser(userInfo: userInfo)
        
        await DynamoDBUtils.putDynamoDBItem(name: userInfo.name, email: userInfo.email, profilePictureURL: userInfo.profilePictureURL!.absoluteString)
    }
    
    func handleSignIn(userInfo: UserProfileInfo) async {
        if let userInfo = try? await self.getExistingUser(email: userInfo.email) {
            loginUser(userInfo: userInfo)
        } else {
            await self.createNewUser(userInfo: UserProfileInfo(name: userInfo.name,
                                                               email: userInfo.email,
                                                               profilePictureURL: userInfo.profilePictureURL))
        }
    }
    
    @objc func goToMainApp() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController") {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true)
        }
    }
    
    func getExistingUser(email: String) async throws -> UserProfileInfo? {
        if let dynamoDBUserInfo = await DynamoDBUtils.getDynamoDBItem(email: email) {
            var userInfo = UserProfileInfo(name: "", email: "", profilePictureURL: nil)
            for (key, value) in dynamoDBUserInfo {
                print(key)
                if case let .s(value) = value {
                    switch key {
                    case "name":
                        userInfo.name = value
                    case "email":
                        userInfo.email = value
                    case "profilePictureURL":
                        if let url = URL(string: value) {
                            userInfo.profilePictureURL = url
                        }
                    default:
                        break
                    }
                }
            }
            return userInfo
        }
        return nil
    }
    
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            Task {
                guard let email = appleIdCredential.email else {
                    Logger.userInfo.debug("Apple Sign In: No email.")
                    print("Apple Sign In: No email.")
                    return
                }
                
                guard let firstName = appleIdCredential.fullName?.givenName else {
                    Logger.userInfo.debug("Apple Sign In: No first name.")
                    print("Apple Sign In: No first name.")
                    return
                }
                guard let lastName = appleIdCredential.fullName?.familyName else {
                    Logger.userInfo.debug("Apple Sign In: No last name.")
                    print("Apple Sign In: No last name.")
                    return
                }
                let name = firstName + " " + lastName
                    
                await handleSignIn(userInfo: UserProfileInfo(name: name, email: email))
            }
            break
            
        // TODO: Needed?
        case let passwordCredential as ASPasswordCredential:
            // Sign in using exisiting iCloud Keychain credential.
            // For the purpose of this demo app, show alert
            goToMainApp()
            break
        default:
            Swift.debugPrint("Not ready yet")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print(error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

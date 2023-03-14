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
                        ASAuthorizationPasswordProvider().createRequest()
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
            guard error == nil else {
                showErrorWithSignIn()
                return
            }
            guard let uuid = signInResult?.user.userID else {
                showErrorWithSignIn()
                return
            }
            guard let profile = signInResult?.user.profile else {
                showErrorWithSignIn()
                return
            }
            
            Task {
                await handleSignIn(uuid: uuid,
                                   name: profile.name,
                                   email: profile.email,
                                   profilePictureURL: profile.imageURL(withDimension: 320)!)
                
                #warning ("TODO change to ProfileViewModel")
                let defaults = UserDefaults.standard
                defaults.set(profile.email, forKey: "email")
                
                self.goToMainApp()
            }
        }
    }
    
    // MARK: Helper functions for Login
    func setCurrentUser(userInfo: UserProfileInfo) {
        Profile.createProfile(uuid: userInfo.uuid,
                              name: userInfo.name,
                              email: userInfo.email,
                              profilePictureURL: userInfo.profilePictureURL) { profile in
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
        
        await DynamoDBUtils.putDynamoDBItem(uuid: userInfo.uuid,
                                            name: userInfo.name,
                                            email: userInfo.email,
                                            profilePictureURL: userInfo.profilePictureURL?.absoluteString ?? "")
    }
    
    func handleSignIn(uuid: String, name: String? = nil, email: String? = nil, profilePictureURL: URL? = nil) async {
        if let userInfo = try? await self.getExistingUser(uuid: uuid) {
            loginUser(userInfo: userInfo)
        } else if let email = email, let name = name {
            await self.createNewUser(userInfo: UserProfileInfo(uuid: uuid,
                                                               name: name,
                                                               email: email,
                                                               profilePictureURL: profilePictureURL))
        }
    }
    
    func showErrorWithSignIn() {
        let message = """
                      It looks like we weren't able to log you in. Please try again. If the issue continues, please contact the developers.
                      """
        let ac = UIAlertController(title: "Well, This is Awkward...", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    @objc func goToMainApp() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController") {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true)
        }
    }
    
    func getExistingUser(uuid: String) async throws -> UserProfileInfo? {
        if let dynamoDBUserInfo = await DynamoDBUtils.getDynamoDBItem(uuid: uuid) {
            var userInfo = UserProfileInfo(uuid: "", name: "", email: "", profilePictureURL: nil)
            for (key, value) in dynamoDBUserInfo {
                print(key)
                if case let .s(value) = value {
                    switch key {
                    case "uuid":
                        userInfo.uuid = value
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
            Logger.dynamoDB.debug("User info being returned.")
            return userInfo
        }
        Logger.dynamoDB.debug("Nil being returned for user info")
        return nil
    }
    
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            Task {
                let name = (appleIdCredential.fullName?.givenName ?? "") + " " + (appleIdCredential.fullName?.familyName ?? "")
                await handleSignIn(uuid: appleIdCredential.user,
                                   name: name,
                                   email: appleIdCredential.email)
                self.goToMainApp()
            }
            break
            
        #warning("TODO needed?")
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

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

class LoginViewController: UIViewController {
    @IBOutlet var appLabel: UILabel!
    @IBOutlet var learnMoreButton: UIButton!
    
    private let dynamoDbClient = Constants.dynamoDbClient
    private let usersTable = Constants.usersTable
    
    public static var userProfile: Profile!
    
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
                if try await !self.userAlreadyExists(email: profile.email) {
                    try await self.createUser(name: profile.name,
                                              email: profile.email,
                                              profilePictureURL: profile.imageURL(withDimension: 320)!.absoluteString)
                }
                let defaults = UserDefaults.standard
                defaults.set(profile.email, forKey: "email")
                
                LoginViewController.userProfile = Profile(name: profile.name,
                                                          email: profile.email,
                                                          profilePictureURL: profile.imageURL(withDimension: 320))
                
                self.goToMainApp()
            }
        }
    }
    
    @objc func goToMainApp() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController") {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true)
        }
    }
    
    func userAlreadyExists(email: String) async throws -> Bool {
        let keyToGet = ["email" : DynamoDBClientTypes.AttributeValue.s(email)]
        let input = GetItemInput(key: keyToGet, tableName: usersTable)
        let response: GetItemOutputResponse
        do {
            response = try await dynamoDbClient.getItem(input: input)
        } catch {
            print("ERROR: \(error.localizedDescription)")
            throw error
        }
        if (response.item != nil) {
            return true
        }
        return false
    }
    
    func createUser(name: String, email: String, profilePictureURL: String) async throws -> PutItemOutputResponse {
        let itemValues = [
            "name": DynamoDBClientTypes.AttributeValue.s(name),
            "email": DynamoDBClientTypes.AttributeValue.s(email),
            "profilePictureURL": DynamoDBClientTypes.AttributeValue.s(profilePictureURL)
        ]
        let input = PutItemInput(item: itemValues, tableName: usersTable)
        do {
            return try await dynamoDbClient.putItem(input: input)
        } catch {
            print("ERROR: \(error.localizedDescription)")
            throw error
        }
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            Task {
                guard let email = appleIdCredential.email else { return }
                
                guard let firstName = appleIdCredential.fullName?.givenName else { return }
                guard let lastName = appleIdCredential.fullName?.familyName else { return }
                let name = firstName + " " + lastName
                
                if try await !self.userAlreadyExists(email: email) {
                    try await self.createUser(name: name,
                                              email: email,
                                              profilePictureURL: "")
                    LoginViewController.userProfile = Profile(name: name, email: email)
                }
                let defaults = UserDefaults.standard
                defaults.set(email, forKey: "email")
                self.goToMainApp()
            }
            break
            
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

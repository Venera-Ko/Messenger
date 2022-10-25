//
//  AppDelegate.swift
//  Messenger
//
//  Created by V K on 05.10.2022.
//

import FirebaseCore

import UIKit
import FacebookCore
import FBSDKLoginKit
import GoogleSignIn
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        ///google integration
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        
        ///google integration latest version
        //        let signInConfig = GIDConfiguration(clientID: "787906017450-6buk3jum3d7bc9h1u8r3mo2nc378m0de.apps.googleusercontent.com")
        //
        //        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
        //            if error != nil || user == nil {
        //              LoginViewController()
        //            } else {
        //              ConversationsViewController()
        //            }
        //          }
        //
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("failed to sign in with google \(error)")
            }
            return
        }
        
//        guard let user == user else {
//            return
//        }
//        if user != nil {
//            print("did signin with google \(user)")
//        }
//
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
            return
        }
        
        DatabaseManager.shared.userExists(with: email) { exists in
            if !exists {
                ///insert to database
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                    lastName: lastName,
                                                                    email: email))
            }
        }
        
        guard let authentication = user.authentication else {
            print("missing auth object off of google user")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
            guard authResult != nil, error == nil else {
                print("failed to log in with google credential")
            return
            }
            
            print("successfully signed in with google credential")
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("google user was disconnected")
    }
}

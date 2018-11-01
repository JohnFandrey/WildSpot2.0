//
//  LoginViewController.swift
//  WildSpot
//
//  Created by John Fandrey on 8/21/18.
//  Copyright © 2018 John Fandrey. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase
import FirebaseUI

class LoginViewController: UIViewController, FUIAuthDelegate, GIDSignInDelegate {
    
    
    @IBOutlet weak var signIn: UIButton!
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    var signOut: Bool = false
    
    override func viewDidLoad() {
        if signOut {
            do {
                try Auth.auth().signOut()
            } catch {
            }
        } else {
            let authUI = FUIAuth.defaultAuthUI()
            authUI?.delegate = self
            configureAuth(fuiAuth: authUI!)
            
        }
    }
    
    // configureAuth is used to get user's logged into firebase.
    
    func configureAuth(fuiAuth: FUIAuth){
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        fuiAuth.providers = provider
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    let name = user!.email?.components(separatedBy: "@")[0]
                    self.displayName = name!
                    UserName.sharedInstance().userName = name!
                    self.segueToMapView()
                }
            } else {
                self.loginSession(fuiAuth: fuiAuth)
            }
        }
    }
    
    func segueToMapView(){
        signOut = true
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    func loginSession(fuiAuth: FUIAuth?) {
        let authViewController = fuiAuth?.authViewController()
        self.present(authViewController!, animated: true){
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            UserName.sharedInstance().userName = (user!.profile.email?.components(separatedBy: "@")[0])!
            // ...
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        if user?.email?.components(separatedBy: "@")[0] != nil {
            UserName.sharedInstance().userName = (self.user!.email?.components(separatedBy: "@")[0])!
        } else {
            UserName.sharedInstance().userName = "unknown"
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        configureAuth(fuiAuth: authUI!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapViewController" {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
}

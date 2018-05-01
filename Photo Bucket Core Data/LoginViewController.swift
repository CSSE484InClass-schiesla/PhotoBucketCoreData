//
//  LoginViewController.swift
//  Photo Bucket Core Data
//
//  Created by CSSE Department on 4/30/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit
import Rosefire
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    let rosefireKey = "d3162b8d-b41e-408f-82af-0bff5c96e3c6"
    
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var rosefireLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        googleLoginButton.style = .wide
        
        rosefireLoginButton.titleLabel?.text = "Rosefire Login"
        rosefireLoginButton.setTitleColor(.white, for: .normal)
        rosefireLoginButton.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 0.9)
        
    }
    
    @IBAction func loginWithRosefire(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self
        Rosefire.sharedDelegate().signIn(registryToken: rosefireKey) {
            (error, result) in
            if let error = error {
                print("Error communicating with Rosefire! \(error.localizedDescription)")
                return
            }
            print("You are now signed in with Rosefire!  username: \(result!.username!)")
            Auth.auth().signIn(withCustomToken: result!.token,
                               completion: self.loginCompletionCallback)
        }
        
    }
   
    func loginCompletionCallback(_ user: User?, _ error: Error?) {
        if let error = error {
            print("Error during log in: \(error.localizedDescription)")
            let ac = UIAlertController(title: "Login failed",
                                       message: error.localizedDescription,
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
        } else {
            appDelegate.handleLogin()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

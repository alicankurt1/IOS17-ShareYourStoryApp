//
//  ViewController.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 28.08.2021.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != ""{
            
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { auth , error  in
                if error != nil{
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Login Error!")
                }else{
                    self.performSegue(withIdentifier: "toStoriesVC", sender: nil)
                }
            }
            
        }else{
            self.makeAlert(title: "Error", message: "Empty Area Error!")
        }
        
        
        
        
        
        
    }
    
    
    @IBAction func signUpClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignUpVC", sender: nil)
    }
    
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}


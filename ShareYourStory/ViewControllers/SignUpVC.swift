//
//  SignUpVC.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 28.08.2021.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpClicked(_ sender: Any) {
        
        if emailText.text != "" && usernameText.text != "" && passwordText.text != ""{
            
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { auth , error  in
                if error != nil{
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Sign Up Error!")
                }else{
                    
                    let fireStore = Firestore.firestore()
                    let userDictonary = ["email" : self.emailText.text!, "username" : self.usernameText.text!, "profileImage" : ""] as [String : Any]
                    
                    fireStore.collection("UserInfo").addDocument(data: userDictonary) { error  in
                        if error != nil{
                            self.makeAlert(title: "Error", message: error?.localizedDescription ?? "UserInfo Error!")
                        }
                    }
                    
                    self.performSegue(withIdentifier: "toStoriesVCFromSignUpVC", sender: nil)
                    
                }
            }
        }else{
            makeAlert(title: "Error", message: "Empty Area Error!")
        }
        
        
    }
    
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    

}

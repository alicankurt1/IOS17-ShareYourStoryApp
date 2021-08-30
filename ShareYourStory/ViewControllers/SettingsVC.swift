//
//  SettingsVC.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 28.08.2021.
//

import UIKit
import Firebase
import SDWebImage

class SettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.isEnabled = false
        
        print("ZZZ" + UserInfoSingleton.sharedUserInfo.profileImageUrl)
        profileImageView.sd_setImage(with: URL(string: UserInfoSingleton.sharedUserInfo.profileImageUrl))
        usernameLabel.text = UserInfoSingleton.sharedUserInfo.username

        // Do any additional setup after loading the view.
        profileImageView.isUserInteractionEnabled = true
        let profileImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(profileImageRecognizer)
        
    }
    
    
    @objc func selectProfileImage(){
      
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profileImageView.image = info[.originalImage] as? UIImage
        updateButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func updateClicked(_ sender: Any) {
        if  picker.isViewLoaded == true{
            
            let storage = Storage.storage()
            let storageReference = storage.reference()
            
            let profileMediaFolder = storageReference.child("profileMedia")            
            
            if let imageData = profileImageView.image?.jpegData(compressionQuality: 0.2){
                let uuid = UUID().uuidString
                let imageReference = profileMediaFolder.child("\(uuid).jpg")
                imageReference.putData(imageData, metadata: nil) { metaData , error  in
                    if error != nil{
                        self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Profile Image Upload Error!")
                    }else{
                        
                        imageReference.downloadURL { url , error  in
                            if error == nil{
                                
                                let imageUrl = url?.absoluteString
                                let fireStore = Firestore.firestore()
                                
                                fireStore.collection("UserInfo").whereField("email", isEqualTo: UserInfoSingleton.sharedUserInfo.email).getDocuments { snapshot , error in
                                    if error == nil && snapshot != nil{
                                        let user = snapshot?.documents[0]
                                        let documentId = user?.documentID
                                       
                                        fireStore.collection("UserInfo").document(documentId!).setData(["profileImage" : imageUrl ?? ""], merge: true)
                                        
                                        fireStore.collection("Stories").whereField("storyOwner", isEqualTo: UserInfoSingleton.sharedUserInfo.email).getDocuments { snapshot , error  in
                                            if error == nil && snapshot != nil && snapshot?.isEmpty == false{
                                                let user = snapshot?.documents[0]
                                                let documentId = user?.documentID
                                                
                                                fireStore.collection("Stories").document(documentId!).setData(["profileImage" : imageUrl ?? ""], merge: true)
                                            }
                                        }
                                        
                                        UserInfoSingleton.sharedUserInfo.profileImageUrl = imageUrl!
                                        
                                        self.makeAlert(title: "Success", message: "Successfully Updated!")
                                        self.updateButton.isEnabled = false
                                        
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
            }
            
            
        }else{
            self.makeAlert(title: "Error", message: "Username cannot be empty!")
        }
        
    }
    
    
    

    @IBAction func logoutClicked(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toLoginVC", sender: nil)
        }catch{
            print("error")
        }
        
        
    }
    
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    

}

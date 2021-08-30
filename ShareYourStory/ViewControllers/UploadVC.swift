//
//  UploadVC.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 28.08.2021.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        uploadImageView.isUserInteractionEnabled = true
        shareButton.isEnabled = false
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        uploadImageView.addGestureRecognizer(imageGestureRecognizer)
        
        
    }
    
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage
        shareButton.isEnabled = true

        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func shareClicked(_ sender: Any) {
        
        // STORAGE
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata , error  in
                if error != nil{
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Upload Error!")
                }else{
                    
                    imageReference.downloadURL { url , error in
                        if error == nil{
                            
                            let imageUrl = url?.absoluteString
                            
                            // FIRESTORE
                            
                            let fireStore = Firestore.firestore()
                            
                            
                            fireStore.collection("Stories").whereField("storyOwner", isEqualTo: UserInfoSingleton.sharedUserInfo.email).getDocuments { snapshot , error in
                                if error != nil{
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                }else{
                                    if snapshot?.isEmpty == false && snapshot != nil{
                                        
                                        for document in snapshot!.documents{
                                            
                                            let documentId = document.documentID
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String]{
                                                if let timeStamp = document.get("dateArray") as? [Timestamp]{
                                                                                                      
                                                    var dateArray = [Date]()
                                                    for i in 0..<timeStamp.count{
                                                        dateArray.append(timeStamp[i].dateValue())
                                                    }
                                                    
                                                    dateArray.append(Date())
                                                    imageUrlArray.append(imageUrl!)
                                                    
                                                    let additionalDictionary = ["imageUrlArray" : imageUrlArray, "dateArray" : dateArray, "profileImage" : UserInfoSingleton.sharedUserInfo.profileImageUrl, "date" : FieldValue.serverTimestamp()] as [String : Any]
                                                    
                                                    fireStore.collection("Stories").document(documentId).setData(additionalDictionary, merge: true) { error  in
                                                        if error == nil{
                                                            self.tabBarController?.selectedIndex = 0
                                                            self.uploadImageView.image = UIImage(named: "question_mark")
                                                            self.shareButton.isEnabled = false
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }else{
                                        
                                        // if user share a story first time
                                                                             
                                        
                                        let currentDate = Date()
                                       
                                        let storyDictionary = ["imageUrlArray" : [imageUrl!], "storyOwner" : UserInfoSingleton.sharedUserInfo.email, "dateArray" : [currentDate], "profileImage" : UserInfoSingleton.sharedUserInfo.profileImageUrl, "date" : FieldValue.serverTimestamp() ] as [String : Any]
                                        
                                        fireStore.collection("Stories").addDocument(data: storyDictionary) { error  in
                                            if error != nil{
                                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            }else{
                                                self.tabBarController?.selectedIndex = 0
                                                self.uploadImageView.image = UIImage(named: "question_mark")
                                                self.shareButton.isEnabled = false

                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                            
                            
                            
                            

                            
                            
                        }
                    }
                    
                }
            }
            
        }
        
        
    }
    
    
    
    
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    

}

//
//  StoriesVC.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 28.08.2021.
//

import UIKit
import Firebase
import SDWebImage

class StoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var storiesTableView: UITableView!
    let fireStoreDatabase = Firestore.firestore()
    var storyArray = [Story]()
    var choosenUserStory : Story?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        storiesTableView.delegate = self
        storiesTableView.dataSource = self
        
        
        getStoriesFromFirebase()
        
        getUserInfo()
        
    }
    
    
    func getStoriesFromFirebase(){
        
        fireStoreDatabase.collection("Stories").order(by: "date", descending: true).addSnapshotListener { snapshot , error  in
            if error != nil{             
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }else{
              
                if snapshot != nil && snapshot?.isEmpty == false{
               
                    self.storyArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents{
                     
                        if let profilePhotoUrl = document.get("profileImage") as? String{
                            if let username = document.get("storyOwner") as? String{
                                if let imageUrlArray = document.get("imageUrlArray") as? [String]{
                                    if let timeStampArray = document.get("dateArray") as? [Timestamp]{
                                        
                                        var dateArray = [Date]()
                                        for i in 0..<timeStampArray.count{
                                            dateArray.append(timeStampArray[i].dateValue())
                                        }
                                        
                                        // IF you want Date Operations like deleting a story which over time:24
                                /*       for i in 0..<dateArray.count{
                                            if let timeDifference = Calendar.current.dateComponents([.hour], from: dateArray[i], to: Date()).hour{
                                                if timeDifference >= 24{
                                                    // DELETE OPERATİON - Actually Update if there are many image.
                                                    // dateArray.remove(i)
                                                    // imageUrlArray.remove(i)
                                                }
                                            }
                                        }
                                 */
                                        
                                        
                                        let story = Story(profilePhoto: profilePhotoUrl, username: username, imageUrlArray: imageUrlArray, dateArray: dateArray)
                                        self.storyArray.append(story)
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    self.storiesTableView.reloadData()
                    
                    
                }else{
                    print("EMPTY")
                }
            }
        }
        
        
    }
    
    
    
    
    func getUserInfo(){
        
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot , error  in
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Get User Info Error!")
            }else if snapshot?.isEmpty == false && snapshot != nil{
                
                for document in snapshot!.documents{
                    // User Info
                    if let username = document.get("username") as? String{
                        if let imageData = document.get("profileImage") as? String{
                            UserInfoSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserInfoSingleton.sharedUserInfo.username = username
                            if imageData == ""{                             
                                UserInfoSingleton.sharedUserInfo.profileImageUrl = ""
                            }else{
                                // URL Transactions SDWebBimage
                                UserInfoSingleton.sharedUserInfo.profileImageUrl = imageData
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath) as! StoriesCell
        cell.profileImageView.sd_setImage(with: URL(string: storyArray[indexPath.row].profilePhoto))
        cell.usernameLabel.text = storyArray[indexPath.row].username
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserStoryVC"{
            let destinationVC = segue.destination as! UserStoryVC
            destinationVC.choosenUserStory = self.choosenUserStory
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenUserStory = storyArray[indexPath.row]
        performSegue(withIdentifier: "toUserStoryVC", sender: nil)
    }
    
    
    
    
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    

  

}

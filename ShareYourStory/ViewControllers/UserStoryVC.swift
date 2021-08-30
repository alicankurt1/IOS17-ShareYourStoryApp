//
//  UserStoryVC.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 30.08.2021.
//

import UIKit
import ImageSlideshow
import SDWebImage

class UserStoryVC: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    var choosenUserStory : Story?
    var imageInputArray = [KingfisherSource]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        
        
        
        
        if let userStories = choosenUserStory{
            
            if userStories.profilePhoto != ""{
                profileImageView.sd_setImage(with: URL(string: userStories.profilePhoto))
            }
            emailLabel.text = userStories.username
            
            for imageUrl in userStories.imageUrlArray{
                imageInputArray.append(KingfisherSource(urlString: imageUrl)!)
            }
            
            
            let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.9))
            imageSlideShow.backgroundColor = UIColor.white
            
            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = UIColor.black
            pageIndicator.pageIndicatorTintColor = UIColor.lightGray
            imageSlideShow.pageIndicator = pageIndicator
            
            imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
            imageSlideShow.setImageInputs(imageInputArray)
            self.view.addSubview(imageSlideShow)
            self.view.bringSubviewToFront(emailLabel)
            self.view.bringSubviewToFront(profileImageView)
            
            
            
        }
        
        
        
    }
    



}

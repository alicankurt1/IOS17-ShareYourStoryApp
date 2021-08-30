//
//  StoriesCell.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 29.08.2021.
//

import UIKit

class StoriesCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.green.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

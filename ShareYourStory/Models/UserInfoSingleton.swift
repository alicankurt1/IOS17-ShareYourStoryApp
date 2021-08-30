//
//  UserInfoSingleton.swift
//  ShareYourStory
//
//  Created by Alican Kurt on 29.08.2021.
//

import Foundation
import UIKit


class UserInfoSingleton{
    
    static let sharedUserInfo = UserInfoSingleton()
    
    
    var email = ""
    var username = ""
    var profileImageUrl = ""
    
    
    private init(){}
    
    
    
}

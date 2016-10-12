//
//  UserModel.swift
//  WODStory
//
//  Created by Yoonjong on 10/5/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class UserModel {
    
    static let currentUser: UserModel = {
        let instance = UserModel()
        return instance
    }()
    
    func clear() {
        id = 0
        username = ""
        email = ""
        authtoken = ""
        is_loggedIn = false
    }
    
    func initCurUser() {
        clear()
        let defaults:UserDefaults = UserDefaults.standard
        if let tempToken = defaults.object(forKey: "Auth_Token") as? String {
            authtoken = tempToken
        }
    }
    
    var id:Int = 0
    var username:String = ""
    var email:String = ""
    var authtoken:String = ""
    
    var is_loggedIn = false

    func setfromJSON(_ json:JSON) {
        
        if let tmpInt = json["id"].int { id = tmpInt }
        if let tmpString = json["username"].string { username = tmpString }
        if let tmpString = json["email"].string { email = tmpString }
        if let tmpString = json["authtoken"].string { authtoken = tmpString }
    }
}

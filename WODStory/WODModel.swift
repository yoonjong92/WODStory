//
//  WODModel.swift
//  WODStory
//
//  Created by Yoonjong on 10/5/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class WODModel {

    var id:Int = 0
    var title:String = ""
    var text:String = ""
    
    func setfromJSON(_ json:JSON) {
        
        if let tmpInt = json["id"].int { id = tmpInt }
        if let tmpString = json["name"].string { title = tmpString }
        if let tmpString = json["email"].string { text = tmpString }
        
    }
    
}

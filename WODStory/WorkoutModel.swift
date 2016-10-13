//
//  WorkoutModel.swift
//  WODStory
//
//  Created by Yoonjong on 10/13/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class WorkoutModel {
    var id:Int = 0
    var wod_id:Int?
    var name:String = ""
    var weight,distance:Int?
    var weight_unit,distance_unit:String?
    var reps:String?
    
    func setfromJSON(_ json:JSON) {
        
        if let tmpInt = json["id"].int { id = tmpInt }
        if let tmpInt = json["wod_id"].int { wod_id = tmpInt }
        if let tmpString = json["name"].string { name = tmpString }
        if let tmpInt = json["weight"].int { weight = tmpInt }
        if let tmpInt = json["distance"].int { distance = tmpInt }
        if let tmpString = json["weight_unit"].string { weight_unit = tmpString }
        if let tmpString = json["distance_unit"].string { distance_unit = tmpString }
        if let tmpString = json["reps"].string { reps = tmpString }
    }
}

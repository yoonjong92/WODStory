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
    var type:Int = 0
    var text:String = ""
    var date:String = ""
    var result_time:String?
    var result_rounds,result_reps:Int?
    var workouts = [WorkoutModel]()
    
    func setfromJSON(_ json:JSON) {
        
        if let tmpInt = json["id"].int { id = tmpInt }
        if let tmpInt = json["type"].int { type = tmpInt }
        if let tmpString = json["title"].string { title = tmpString }
        if let tmpString = json["email"].string { text = tmpString }
        if let tmpString = json["date"].string { date = tmpString }
        if let tmpString = json["result_time"].string { result_time = tmpString }
        if let tmpInt = json["result_rounds"].int { result_rounds = tmpInt }
        if let tmpInt = json["result_reps"].int { result_reps = tmpInt }
        
        workouts.removeAll()
        if json["workouts"] != nil {
            let workoutCount = json["workouts"].count
            for i in 0 ..< workoutCount {
                let newWorkout = WorkoutModel()
                newWorkout.setfromJSON(json["workouts"][i])
                workouts.append(newWorkout)
            }
        }
    }
    
}

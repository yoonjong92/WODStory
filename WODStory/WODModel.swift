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
    var round:Int?
    var result_time:Int?
    var result_rounds,result_reps:Int?
    var emomminnute,emomperminute:Int?
    var workouts = [WorkoutModel]()
    
    func setfromJSON(_ json:JSON) {
        
        if let tmpInt = json["id"].int { id = tmpInt }
        if let tmpString = json["title"].string { title = tmpString }
        if let tmpInt = json["type"].int { type = tmpInt }
        if let tmpString = json["text"].string { text = tmpString }
        if let tmpString = json["date"].string { date = tmpString }
        if let tmpInt = json["round"].int { round = tmpInt }
        if let tmpInt = json["result_time"].int { result_time = tmpInt }
        if let tmpInt = json["result_rounds"].int { result_rounds = tmpInt }
        if let tmpInt = json["result_reps"].int { result_reps = tmpInt }
        if let tmpInt = json["emomminnute"].int { emomminnute = tmpInt }
        if let tmpInt = json["emomperminute"].int { emomperminute = tmpInt }
        
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

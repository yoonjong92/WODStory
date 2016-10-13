//
//  WODDetailViewController.swift
//  WODStory
//
//  Created by Yoonjong on 10/13/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class WODDetailViewController: UIViewController {

    var wod:WODModel?
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var wodTitle: UILabel!
    @IBOutlet weak var textTopSpace: NSLayoutConstraint!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultTopSpace: NSLayoutConstraint!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        date.text = wod?.date
        wodTitle.text = wod?.title
        text.text = wod?.text
        if text.text == "" {
            textTopSpace.constant = 0
        }else {
            textTopSpace.constant = 8
        }
        type.text = WODType[(wod?.type)!]
        resultView.isHidden = false
        resultTopSpace.constant = 8
        if wod?.result_time != nil {
            result.text = wod?.result_time
        }
        else if wod?.result_rounds != nil && wod?.result_rounds != 0 {
            result.text = "\((wod?.result_rounds)!)"
            if wod?.result_reps != nil {
                result.text = "\((wod?.result_rounds)!) \((wod?.result_reps)!)"
            }
        }else if wod?.result_reps != nil {
            result.text = "\((wod?.result_reps)!)"
            
        }else {
            resultView.isHidden = true
            resultTopSpace.constant = 0
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableViewHeight.constant = CGFloat((wod?.workouts.count)!) * 60
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WODDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wod!.workouts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WODDetailWorkOutTableViewCell", for: indexPath) as? WODDetailWorkOutTableViewCell
        
        if cell == nil {
            return WODDetailWorkOutTableViewCell()
        }
        let workout = wod!.workouts[indexPath.row]
        var infoText = workout.name.capitalized
        if workout.weight != nil {
            infoText += " \(workout.weight!)"
            if workout.weight_unit != nil {
                infoText += workout.weight_unit!
            }
        }else if workout.distance != nil {
            infoText += " \(workout.distance!)"
            if workout.distance_unit != nil {
                infoText += workout.distance_unit!
            }
        }
        cell?.workoutInfo.text = infoText
        cell?.reps.text = workout.reps
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class WODDetailWorkOutTableViewCell : UITableViewCell {
    
    @IBOutlet weak var workoutInfo: UILabel!
    @IBOutlet weak var reps: UILabel!
}

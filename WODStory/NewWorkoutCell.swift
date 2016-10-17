//
//  NewWorkoutCell.swift
//  WODStory
//
//  Created by Yoonjong on 10/14/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class NewWorkoutCell: UIView {
    
    weak var delegate:NewWorkoutCellDelegate?

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var weightUnit: UITextField!
    @IBOutlet weak var content: UITextField!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instancefromNib() -> NewWorkoutCell {
        return UINib(nibName: "NewWorkoutCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NewWorkoutCell
    }

    @IBAction func deleteButtonTouchUpInside(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Delete a workout", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            self.removeFromSuperview()
            if self.delegate != nil {
                self.delegate?.needRearrange()
            }
        }))
        if delegate != nil {
            (delegate as! UIViewController).present(alert, animated: true, completion: nil)
        }
    }
}

protocol NewWorkoutCellDelegate : class {
    func needRearrange()
}

extension NewWorkoutCellDelegate {
    func needRearrange() {}
    func newWorkoutCell(newWorkoutCell:NewWorkoutCell, didnameEditingChanged text:String) {}
}

//
//  WODListTableViewCell.swift
//  WODStory
//
//  Created by Yoonjong on 10/12/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class WODListTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var workouts: UILabel!
    @IBOutlet weak var result: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

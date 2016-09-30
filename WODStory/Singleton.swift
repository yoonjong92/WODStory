//
//  Singleton.swift
//  WODStory
//
//  Created by 박윤종 on 2016. 9. 26..
//  Copyright © 2016년 박윤종. All rights reserved.
//

import UIKit

class Singleton {
    static let sharedInstance: Singleton = {
        let instance = Singleton()
        return instance
    }()
}

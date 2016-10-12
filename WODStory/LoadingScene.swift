//
//  LoadingScene.swift
//  WODStory
//
//  Created by Yoonjong on 10/11/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class LoadingScene {
    static let sharedInstance: LoadingScene = {
        let instance = LoadingScene()
        return instance
    }()
    
    var coverView:UIView! = UIView()
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    init() {
        coverView.addSubview(spinner)
    }
    
    func show() {
        if let mainwindow = UIApplication.shared.keyWindow {
            coverView.backgroundColor = UIColor.black
            coverView.alpha = 0.5
            coverView.frame = mainwindow.frame
            spinner.center = CGPoint(x: coverView.frame.size.width/2, y: coverView.frame.size.height/2)
            mainwindow.addSubview(coverView)
            spinner.startAnimating()
        }
    }
    
    func hide() {
        spinner.stopAnimating()
        coverView.removeFromSuperview()
    }
}

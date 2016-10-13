//
//  MainTabBarController.swift
//  WODStory
//
//  Created by Yoonjong on 10/13/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: self.tabBar.frame.size.width/3, y: 0, width: self.tabBar.frame.size.width/3, height: self.tabBar.frame.size.height) )
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(newWODButtonTouchUpInside), for: .touchUpInside)
        self.tabBar.addSubview(button)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newWODButtonTouchUpInside(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Logging", bundle: nil)
        let destVC = storyboard.instantiateInitialViewController()
        self.present(destVC!, animated: true, completion: nil)
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

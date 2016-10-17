//
//  FeedViewController.swift
//  WODStory
//
//  Created by Yoonjong on 10/5/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    var needRefresh = true
    var onceToken = true
    
    @IBOutlet weak var tableView: WODListTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.VC = self
        tableView.user = UserModel.currentUser
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserModel.currentUser.is_loggedIn == false {
            if UserModel.currentUser.authtoken != "" {
                API_Signin()
            }else {
                didFailLogin()
            }
        }else {
            didSuccessLogin()
        }
    }
    
    func didFailLogin() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let destVC = storyboard.instantiateInitialViewController()
        self.present(destVC!, animated: true, completion: nil)
        return
    }
    
    func didSuccessLogin() {
        if onceToken {
            API_WorkoutTypeList()
            onceToken = false
        }
        if needRefresh {
            needRefresh = false
            tableView.refresh(clear: true)
        }
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

extension FeedViewController { // Networking
    func API_Signin() {
        
        let urlPath = "\(URL_PATH)/signin/"
        let url: URL = URL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        print(url)
        
        request.addValue("Token \(UserModel.currentUser.authtoken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = TimeInterval(REQUEST_TIMEOUT)
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) {(response, data, error) in
            if((error) != nil) {
                // If there is an error in the web request, print it to the console
                print(error?.localizedDescription)
                self.didFailLogin()
                return
            }
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                if jsonResult!.count > 0 {
                    
                    let json = JSON(jsonResult!)
                    
                    if json["authtoken"] != nil {
                        UserModel.currentUser.setfromJSON(json)
                        UserModel.currentUser.is_loggedIn = true
                        let defaults:UserDefaults = UserDefaults.standard
                        defaults.setValue(UserModel.currentUser.authtoken, forKey: "Auth_Token")
                        self.didSuccessLogin()
                        return
                    }
                }
                else {
                }
                
            } catch {
                print(error)
            }
            self.didFailLogin()
        }
    }
    
    func API_WorkoutTypeList() {
        
        let urlPath = "\(URL_PATH)/workouttype/"
        let url: URL = URL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        print(url)
        
        request.addValue("Token \(UserModel.currentUser.authtoken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = TimeInterval(REQUEST_TIMEOUT)
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) {(response, data, error) in
            if((error) != nil) {
                // If there is an error in the web request, print it to the console
                print(error?.localizedDescription)
                self.didFailLogin()
                return
            }
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                if jsonResult!.count > 0 {
                    
                    let json = JSON(jsonResult!)
                    for i in 0 ..< json.count {
                        if let tmpString = json[i].string { WorkoutTypeList.append(tmpString) }
                    }
                    print(WorkoutTypeList)
                }
                else {
                }
                
            } catch {
                print(error)
            }
        }
    }
}

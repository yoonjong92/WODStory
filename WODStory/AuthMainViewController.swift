//
//  AuthMainViewController.swift
//  WODStory
//
//  Created by Yoonjong on 10/11/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class AuthMainViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func startbuttonTouchUpInside(_ sender: UIButton) {
        LoadingScene.sharedInstance.show()
        sendApi_User()
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

extension AuthMainViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension AuthMainViewController { // networking
    func sendApi_User() {
        let urlPath = "\(URL_PATH)/users/"
        let url: URL = URL(string: urlPath)!
        print(url)
        let bodyData: NSMutableDictionary = [
            "email": "a@a.a",
            "password": "1234",
            "username": (username.text)!,
        ]
        print(bodyData)
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        let bodyJson = JSON(bodyData)
        let bodyString = bodyJson.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions()) as String!
        print(bodyString!)
        print(url)
        
        request.httpBody = bodyString?.data(using: String.Encoding.utf8)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = TimeInterval(REQUEST_TIMEOUT)
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) {(response, data, error) in
            if((error) != nil) {
                // If there is an error in the web request, print it to the console
                print(error?.localizedDescription)
                LoadingScene.sharedInstance.hide()
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
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                }
                
            } catch {
                print(error)
            }
        }
        LoadingScene.sharedInstance.hide()
    }
}

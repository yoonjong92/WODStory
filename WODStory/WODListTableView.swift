//
//  WODListTableView.swift
//  WODStory
//
//  Created by Yoonjong on 10/12/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class WODListTableView: UITableView {

    var defaultURL = "\(URL_PATH)/wods/?limit=20&offset=0"
    var nextURL:String?
    var previousURL:String?
    var useDefault = true
    
    var wods = [WODModel]()
    var isLoading = false
    
    var user:UserModel? {
        didSet {
            defaultURL = "\(URL_PATH)/wods/?user_id=\((user?.id)!)&limit=20&offset=0"
        }
    }
    
    func refresh() {
        useDefault = true
        wods.removeAll()
        self.reloadData()
        searchStart()
    }
    
    func searchStart() {
        if useDefault == true {
            API_WODList(urlString: defaultURL)
            useDefault = false
        }else if nextURL != nil {
            API_WODList(urlString: nextURL!)
            nextURL = nil
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension WODListTableView { //networking
    func API_WODList(urlString:String) {
        
        let urlPath = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url: URL = URL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        print(url)
        
        request.addValue("Token \(UserModel.currentUser.authtoken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = TimeInterval(REQUEST_TIMEOUT)
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) {(response, data, error) in
            print(response)
            if((error) != nil) {
                // If there is an error in the web request, print it to the console
                print(error?.localizedDescription)
                self.isLoading = false
                return
            }
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                
                if jsonResult!.count > 0 {
                    
                    let json = JSON(jsonResult!)
                    
                    
                    if json["results"] != nil{
                        let resultjson = json["results"]
                        let wodscount = resultjson.count
                        
                        var tempwods = [WODModel]()
                        
                        for i in 0  ..< wodscount
                        {
                            let newWOD = WODModel()
                            newWOD.setfromJSON(resultjson[i])
                            tempwods.append(newWOD)
                        }
                        
                        self.wods = tempwods
                    }
                }
                else {
                    print("no wod")
                }
                
            } catch {
                print(error)
            }
        }
        self.isLoading = false
        self.reloadData()
    }
}

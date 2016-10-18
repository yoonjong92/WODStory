//
//  SearchViewController.swift
//  WODStory
//
//  Created by Yoonjong on 10/18/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    var searchKeyWord:String?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: SearchWODListTableView!
    
    var recommendTableView: UITableView!
    var matchList = [String]()
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        searchBar.delegate = self
        
        tableView.user = UserModel.currentUser
        tableView.user?.id = 1
        tableView.VC = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.isRemain = false
        tableView.reloadData()
        
        recommendTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120))
        recommendTableView.layer.borderColor = UIColor.black.cgColor
        recommendTableView.layer.borderWidth = 1
        recommendTableView.delegate = self
        recommendTableView.dataSource = self
        recommendTableView.register(UINib(nibName: "RecommendTableViewCell", bundle: nil), forCellReuseIdentifier: "RecommendTableViewCell")
        recommendTableView.isScrollEnabled = false
        
        searchBar.inputAccessoryView = recommendTableView
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if searchKeyWord != nil {
            searchBar.text = searchKeyWord
            searchBarSearchButtonClicked(searchBar)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        matchList.removeAll()
        var count = 0
        for workoutType in WorkoutTypeList {
            let cont = workoutType.lowercased().replacingOccurrences(of: " ", with: "")
            let word = searchText.lowercased().replacingOccurrences(of: " ", with: "")
            if cont.contains(word) || word == "" {
                matchList.append(workoutType)
                count += 1
                if count > 2 {
                    break
                }
            }
        }
        recommendTableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.defaultURL = "\(URL_PATH)/wodsearch/?user_id=%d&name=\((searchBar.text?.lowercased())!)&limit=20&offset=0"
        tableView.refresh(clear: true)
        searchBar.resignFirstResponder()
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

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendTableViewCell", for: indexPath) as? RecommendTableViewCell
        
        if cell == nil {
            return RecommendTableViewCell()
        }
        cell?.name.text = matchList[indexPath.row].capitalized
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar?.text = matchList[indexPath.row].capitalized
        searchBarSearchButtonClicked(searchBar)
    }
}

class SearchWODListTableView : WODListTableView {
    
    override func searchStart() {
        if useDefault == true {
            API_WODList(urlString: String(format: defaultURL,(user?.id)!))
            useDefault = false
        }else if nextURL != nil {
            API_WODList(urlString: nextURL!)
            nextURL = nil
        }
        
    }
    
    override func API_WODList(urlString:String) {
        
        let urlPath = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
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
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.refreshCtr?.endRefreshing()
                }
                return
            }
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                
                if jsonResult!.count > 0 {
                    
                    let json = JSON(jsonResult!)
                    
                    if let tmpString = json["next"].string {
                        self.nextURL = tmpString
                    }else {
                        self.isRemain = false
                    }
                    
                    if json["results"] != nil{
                        let resultjson = json["results"]
                        let wodscount = resultjson.count
                        
                        var tempwods = [WODModel]()
                        
                        for i in 0  ..< wodscount
                        {
                            let newWOD = WODModel()
                            newWOD.setfromJSON(resultjson[i]["wod"])
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
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshCtr?.endRefreshing()
                self.reloadData()
            }
        }
    }
}

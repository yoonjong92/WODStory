//
//  WODListTableView.swift
//  WODStory
//
//  Created by Yoonjong on 10/12/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class WODListTableView: UITableView {
    
    weak var VC:UIViewController?

    var defaultURL = "\(URL_PATH)/wods/?user_id=%d&limit=20&offset=0"
    var nextURL:String?
    var previousURL:String?
    var useDefault = true
    
    var wods = [WODModel]()
    var isLoading = false
    var isRemain = true
    var refreshCtr:UIRefreshControl?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    func setup() {
        self.delegate = self
        self.dataSource = self
        self.register(UINib(nibName: "WODListTableViewCell", bundle: nil), forCellReuseIdentifier: "WODListTableViewCell")
        
        self.register(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
        
        refreshCtr = UIRefreshControl()
        self.addSubview(refreshCtr!)
        refreshCtr?.addTarget(self, action: #selector(WODListTableView.refreshCtrValueChanged), for: .valueChanged)
        
    }
    
    var user:UserModel?
    
    func refreshCtrValueChanged(sender:UIRefreshControl) {
        refresh()
    }
    
    func refresh(clear:Bool = false) {
        isRemain = true
        useDefault = true
        wods.removeAll()
        if clear == true {
            self.reloadData()
        }
        searchStart()
    }
    
    func searchStart() {
        if useDefault == true {
            API_WODList(urlString: String(format: defaultURL,(user?.id)!))
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

extension WODListTableView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRemain == true {
            return wods.count + 1
        }
        return wods.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= wods.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "WODListTableViewCell", for: indexPath) as? WODListTableViewCell
        
        if cell == nil {
            return WODListTableViewCell()
        }
        cell?.date.text = wods[indexPath.row].date
        cell?.title.text = wods[indexPath.row].title
        cell?.type.text = WODType[wods[indexPath.row].type]
        cell?.result.text = ""
        if wods[indexPath.row].type == 1 {
            if wods[indexPath.row].result_time != nil {
                let min = wods[indexPath.row].result_time! / 60
                let sec = wods[indexPath.row].result_time! % 60
                if sec < 10 {
                    cell?.result.text = "\(min):0\(sec)"
                }else {
                    cell?.result.text = "\(min):\(sec)"
                }
            }
        }else if wods[indexPath.row].type == 2 {
            if wods[indexPath.row].result_rounds != nil && wods[indexPath.row].result_rounds != 0 {
                cell?.result.text = "\((wods[indexPath.row].result_rounds)!)"
                if wods[indexPath.row].result_reps != nil {
                    cell?.result.text = "\((wods[indexPath.row].result_rounds)!) \((wods[indexPath.row].result_reps)!)"
                }
            }else if wods[indexPath.row].result_reps != nil {
                cell?.result.text = "\((wods[indexPath.row].result_reps)!)"
            }
        }else if wods[indexPath.row].type == 3 {
            if wods[indexPath.row].emomminnute != nil {
                cell?.result.text = "\((wods[indexPath.row].emomminnute)!)min"
            }
        }
        
        cell?.workouts.text = ""
        if wods[indexPath.row].workouts.count > 0 {
            cell?.workouts.text = wods[indexPath.row].workouts[0].name
            for i in 1 ..< wods[indexPath.row].workouts.count {
                cell?.workouts.text = (cell?.workouts.text)! + ", \(wods[indexPath.row].workouts[i].name)"
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= wods.count {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "WODDetailView") as! WODDetailViewController
        destVC.wod = wods[indexPath.row]
        VC?.navigationController?.pushViewController(destVC, animated: true)
    }
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
            DispatchQueue.main.async {
                self.isRemain = false
                self.isLoading = false
                self.refreshCtr?.endRefreshing()
                self.reloadData()
            }
        }
    }
}

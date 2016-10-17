//
//  LoggingViewController.swift
//  WODStory
//
//  Created by Yoonjong on 10/13/16.
//  Copyright © 2016 박윤종. All rights reserved.
//

import UIKit

class LoggingViewController: UIViewController {
    
    let workoutCellHeight:CGFloat = 188

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var wodTypeButtonView: UIView!
    @IBOutlet weak var for_timeButton: WODTypeButton!
    @IBOutlet weak var for_timeButtonText: UILabel!
    @IBOutlet weak var amrapButton: WODTypeButton!
    @IBOutlet weak var amrapButtonText: UILabel!
    @IBOutlet weak var emomButton: WODTypeButton!
    @IBOutlet weak var emomButtonText: UILabel!
    
    @IBOutlet weak var resultViewHeight: NSLayoutConstraint!
    @IBOutlet weak var fortimeResultView: UIView!
    @IBOutlet weak var amrapResultView: UIView!
    @IBOutlet weak var emomResultView: UIView!
    
    @IBOutlet weak var fortimeRounds: UITextField!
    @IBOutlet weak var fortimeResultTime: UITextField!
    var minutePickerData = [Int]()
    var secondPickerData = [Int]()
    var timePicker = UIPickerView()
    
    @IBOutlet weak var amrapRounds: UITextField!
    @IBOutlet weak var amrapReps: UITextField!
    
    @IBOutlet weak var emomTotalMinute: UITextField!
    @IBOutlet weak var emomPerMinute: UITextField!
    
    @IBOutlet weak var workoutContainerView: UIView!
    @IBOutlet weak var workoutContainerViewHeight: NSLayoutConstraint!
    
    var recommendTableView: UITableView!
    var matchList = [String]()
    
    let doneToolbar: UIToolbar = UIToolbar()
    var activeField:UITextField?
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        
        let datepicker = UIDatePicker()
        datepicker.datePickerMode = UIDatePickerMode.date
        dateText.inputView = datepicker
        datepicker.addTarget(self, action: #selector(LoggingViewController.datePickerValueChanged), for: .valueChanged)
        
        datePickerValueChanged(sender: datepicker)
        
        for i in 0 ..< 100 {
            minutePickerData.append(i)
        }
        for i in 0 ..< 60 {
            secondPickerData.append(i)
        }
        
        timePicker.delegate = self
        timePicker.dataSource = self
        fortimeResultTime.inputView = timePicker
        
        fortimeResultTime.text = "0:00"
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(LoggingViewController.doneButtonPressed))
        
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        
        
        self.dateText.inputAccessoryView = doneToolbar
        self.titleText.inputAccessoryView = doneToolbar
        self.textView.inputAccessoryView = doneToolbar
        self.fortimeRounds.inputAccessoryView = doneToolbar
        self.fortimeResultTime.inputAccessoryView = doneToolbar
        self.amrapRounds.inputAccessoryView = doneToolbar
        self.amrapReps.inputAccessoryView = doneToolbar
        self.emomTotalMinute.inputAccessoryView = doneToolbar
        self.emomPerMinute.inputAccessoryView = doneToolbar
        
        
        wodTypeButtonView.layer.borderColor = UIColor.black.cgColor
        wodTypeButtonView.layer.borderWidth = 1
        
        for_timeButton.titleText = for_timeButtonText
        amrapButton.titleText = amrapButtonText
        emomButton.titleText = emomButtonText
        
        fortimeResultView.frame.size.height = 100
        for_timeButtonTouchUpInside(for_timeButton)
        
        recommendTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120))
        recommendTableView.layer.borderColor = UIColor.black.cgColor
        recommendTableView.layer.borderWidth = 1
        recommendTableView.delegate = self
        recommendTableView.dataSource = self
        recommendTableView.register(UINib(nibName: "RecommendTableViewCell", bundle: nil), forCellReuseIdentifier: "RecommendTableViewCell")
        recommendTableView.isScrollEnabled = false
        
        
        addWorkout()
        
        // Do any additional setup after loading the view.
    }
    
    func doneButtonPressed() {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Delete a WOD", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func for_timeButtonTouchUpInside(_ sender: WODTypeButton) {
        for_timeButton.isSelected = true
        fortimeResultView.isHidden = false
        amrapButton.isSelected = false
        amrapResultView.isHidden = true
        emomButton.isSelected = false
        emomResultView.isHidden = true
        resultViewHeight.constant = fortimeResultView.frame.size.height
    }
    
    @IBAction func amrapButtonTouchUpInside(_ sender: WODTypeButton) {
        for_timeButton.isSelected = false
        fortimeResultView.isHidden = true
        amrapButton.isSelected = true
        amrapResultView.isHidden = false
        emomButton.isSelected = false
        emomResultView.isHidden = true
        resultViewHeight.constant = amrapResultView.frame.size.height
    }
    
    @IBAction func emomButtonTouchUpInside(_ sender: WODTypeButton) {
        for_timeButton.isSelected = false
        fortimeResultView.isHidden = true
        amrapButton.isSelected = false
        amrapResultView.isHidden = true
        emomButton.isSelected = true
        emomResultView.isHidden = false
        resultViewHeight.constant = emomResultView.frame.size.height
    }

    @IBAction func doneButtonTouchUpInside(_ sender: UIBarButtonItem) {
        let bodyData = NSMutableDictionary()
        bodyData.setValue(self.dateText.text, forKey: "date")
        var title = self.titleText.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if title == "" {
            title = self.titleText.placeholder
        }
        bodyData.setValue(title, forKey: "title")
        bodyData.setValue(self.textView.text, forKey: "text")
        if self.for_timeButton.isSelected == true {
            bodyData.setValue(1, forKey: "type")
            if fortimeRounds.text == "" {
                bodyData.setValue(fortimeRounds.placeholder, forKey: "round")
            }else {
                bodyData.setValue(fortimeRounds.text, forKey: "round")
            }
            bodyData.setValue(timePicker.selectedRow(inComponent: 0) * 60 + timePicker.selectedRow(inComponent: 1), forKey: "result_time")
        }else if self.amrapButton.isSelected == true {
            bodyData.setValue(2, forKey: "type")
            if amrapRounds.text != "" {
                bodyData.setValue(amrapRounds.text, forKey: "result_rounds")
            }
            if amrapReps.text != "" {
                bodyData.setValue(amrapReps.text, forKey: "result_reps")
            }else {
                bodyData.setValue(amrapReps.placeholder, forKey: "result_reps")
            }
        }else if self.emomButton.isSelected == true {
            bodyData.setValue(2, forKey: "type")
            if emomTotalMinute.text != "" {
                bodyData.setValue(emomTotalMinute.text, forKey: "emomminute")
            }
            else {
                bodyData.setValue(emomTotalMinute.placeholder, forKey: "emomminute")
            }
            if emomPerMinute.text != "" {
                bodyData.setValue(emomPerMinute.text, forKey: "emomperminute")
            }else {
                bodyData.setValue(emomPerMinute.placeholder, forKey: "emomperminute")
            }
        }
        
        let workoutArray = NSMutableArray()
        for i in 0 ..< workoutContainerView.subviews.count {
            let workoutBody = NSMutableDictionary()
            let view = workoutContainerView.subviews[i] as! NewWorkoutCell
            let name = view.name.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            if name == "" {
                let alertView = UIAlertView(title: nil, message: "Need name of Workout", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
                return
            }else {
                workoutBody.setValue(name, forKey: "name")
                if WorkoutTypeList.contains(name!) == false {
                    WorkoutTypeList.append(name!)
                }
            }
            if view.weight.text != "" {
                workoutBody.setValue(view.weight.text, forKey: "weight")
                if view.weightUnit.text != "" {
                    workoutBody.setValue(view.weightUnit.text, forKey: "weight_unit")
                }else {
                    workoutBody.setValue(view.weightUnit.placeholder, forKey: "weight_unit")
                }
            }
            let content = view.content.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if content == "" {
                let alertView = UIAlertView(title: nil, message: "Need content of Workout", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
                return
            }else {
                workoutBody.setValue(content, forKey: "content")
            }
            workoutArray.add(workoutBody)
        }
        bodyData.setValue(workoutArray, forKey: "workouts")
        
        let alert = UIAlertController(title: nil, message: "Post a WOD", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Post", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            
            LoadingScene.sharedInstance.show()
            self.API_NewWOD(bodydata: bodyData)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateText.text = dateFormatter.string(from: sender.date)
        titleText.placeholder = "\((dateText.text?.replacingOccurrences(of: "-", with: ""))!) WOD"
    }
    
    func addWorkout() {
        let view = NewWorkoutCell.instancefromNib()
        view.delegate = self
        view.frame = CGRect(x: 0, y: CGFloat(workoutContainerView.subviews.count) * workoutCellHeight, width: self.view.frame.size.width, height: workoutCellHeight)
        view.name.inputAccessoryView = recommendTableView
        view.name.addTarget(self, action: #selector(LoggingViewController.workoutNameEditBegin), for: .editingDidBegin)
        view.name.addTarget(self, action: #selector(LoggingViewController.workoutNameEditChanged), for: .editingChanged)
        view.name.addTarget(self, action: #selector(LoggingViewController.workoutNameEditEnd), for: .editingDidEnd)
        view.weight.inputAccessoryView = doneToolbar
        view.weightUnit.inputAccessoryView = doneToolbar
        view.content.inputAccessoryView = doneToolbar
        workoutContainerView.addSubview(view)
        workoutContainerViewHeight.constant = CGFloat(workoutContainerView.subviews.count) * workoutCellHeight
        
    }
    
    func workoutNameEditBegin(sender:UITextField) {
        activeField = sender
        workoutNameEditChanged(sender: sender)
    }
    
    func workoutNameEditChanged(sender:UITextField) {
        matchList.removeAll()
        var count = 0
        for workoutType in WorkoutTypeList {
            let cont = workoutType.lowercased().replacingOccurrences(of: " ", with: "")
            let word = sender.text?.lowercased().replacingOccurrences(of: "", with: "")
            if cont.contains(word!) || word == "" {
                matchList.append(workoutType)
                count += 1
                if count > 2 {
                    break
                }
            }
        }
        recommendTableView.reloadData()
    }
    
    func workoutNameEditEnd(sender:UITextField) {
        activeField = nil
    }
    
    @IBAction func addWorkoutButtonTouchUpInside(_ sender: AddWorkoutButton) {
        addWorkout()
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

extension LoggingViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return minutePickerData.count
        }else {
            return secondPickerData.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(minutePickerData[row])"
        }else {
            return "\(secondPickerData[row])"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let min = pickerView.selectedRow(inComponent: 0)
        let sec = pickerView.selectedRow(inComponent: 1)
        var secString = String(sec)
        if sec < 10 {
            secString = "0\(sec)"
        }
        fortimeResultTime.text = "\(min):\(secString)"
    }
}

extension LoggingViewController : NewWorkoutCellDelegate {
    func needRearrange() {
        for i in 0 ..< workoutContainerView.subviews.count {
            workoutContainerView.subviews[i].frame.origin.y = CGFloat(i) * workoutCellHeight
        }
        workoutContainerViewHeight.constant = workoutCellHeight * CGFloat(workoutContainerView.subviews.count)
    }
}

extension LoggingViewController : UITableViewDelegate, UITableViewDataSource {
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
        if activeField != nil {
            activeField?.text = matchList[indexPath.row].capitalized
            activeField?.resignFirstResponder()
        }
    }
}

extension LoggingViewController { // network
    func API_NewWOD(bodydata:NSMutableDictionary) {
        let urlPath = "\(URL_PATH)/wods/"
        let url: URL = URL(string: urlPath)!
        print(url)
        print(bodydata)
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        let bodyJson = JSON(bodydata)
        let bodyString = bodyJson.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions()) as String!
        print(bodyString!)
        print(url)
        
        request.httpBody = bodyString?.data(using: String.Encoding.utf8)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(UserModel.currentUser.authtoken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(REQUEST_TIMEOUT)
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) {(response, data, error) in
            if((error) != nil) {
                // If there is an error in the web request, print it to the console
                print(error?.localizedDescription)
            }
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                if jsonResult!.count > 0 {
                    
                    let json = JSON(jsonResult!)
                    
                    if json["id"] != nil {
                        print("success")
                        self.dismiss(animated: true, completion: {
                            LoadingScene.sharedInstance.hide()
                        })
                        return
                        
                    }
                }
                
            } catch {
                print(error)
            }
        }
        LoadingScene.sharedInstance.hide()
        print("fail")
    }
}

class WODTypeButton : UIButton {
    var titleText:UILabel?
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.backgroundColor = UIColor.red
                self.titleText?.textColor = UIColor.white
            }else {
                self.backgroundColor = UIColor.white
                self.titleText?.textColor = UIColor.black
            }
        }
    }
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.5
            }else {
                self.alpha = 1
            }
        }
    }
}

class AddWorkoutButton : UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.5
            }else {
                self.alpha = 1
            }
        }
    }
}

class RecommendTableViewCell : UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
}

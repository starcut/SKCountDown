//
//  SettingViewController.swift
//  Demo
//
//  Created by 清水 脩輔 on 2019/05/27.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit

open class modelClass: NSObject {
    var id: Int = 0
    var text: String = ""
    var start: Date = Date()
    var end: Date = Date()
    var remainingTime: Double = .zero
    var initialRemainingTime: Double = .zero
    var isStopped: CountDownStatus = .playing
    
    override init() {
        super.init()
    }
    
    init(id: Int,
         text: String,
         start: Date,
         end:Date,
         remainingTime: Double,
         initialRemainingTime: Double,
         isStopped: CountDownStatus) {
        self.id = id
        self.text = text
        self.start = start
        self.end = end
        self.remainingTime = remainingTime
        self.initialRemainingTime = initialRemainingTime
        self.isStopped = isStopped
        
        super.init()
    }
}

var modelArray: [modelClass] = []

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    fileprivate var timeItem: [[Int]] = [[],[],[]]
    
    @IBOutlet fileprivate weak var tableView: UITableView?
    @IBOutlet fileprivate weak var datePicker: UIDatePicker?
    @IBOutlet fileprivate weak var countDownPicker: UIPickerView?
    @IBOutlet fileprivate weak var segmentControl: UISegmentedControl?
    
    fileprivate let HOUR_MAX: Int = 24
    fileprivate let MINUTE_MAX: Int = 60
    fileprivate let SECOND_MAX: Int = 60
    
    fileprivate var selectedHour: Int = 0
    fileprivate var selectedMinute: Int = 0
    fileprivate var selectedSecond: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let start: Date = SKDateFormat.createDateTime(date: Date(),
                                                      identifier: "ja_JP")
        let text1: String = "04:08:30"
        let model1: modelClass = .init(id: 0,
                                       text: text1,
                                       start: start,
                                       end: start.addingTimeInterval(UtilTime.transformStringToSecond(timeString: text1)),
                                       remainingTime: .zero,
                                       initialRemainingTime: UtilTime.transformStringToSecond(timeString: text1),
                                       isStopped: .playing)
        let text2: String = "00:05:30"
        let model2: modelClass = .init(id: 1,
                                       text: text2,
                                       start: start,
                                       end: start.addingTimeInterval(UtilTime.transformStringToSecond(timeString: text2)),
                                       remainingTime: .zero,
                                       initialRemainingTime: UtilTime.transformStringToSecond(timeString: text2),
                                       isStopped: .playing)
        modelArray.append(model1)
        modelArray.append(model2)
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.countDownPicker?.delegate = self
        self.countDownPicker?.dataSource = self
        
        for hour in 0 ..< HOUR_MAX {
            self.timeItem[0].append(hour)
        }
        for minute in 0 ..< MINUTE_MAX {
            self.timeItem[1].append(minute)
        }
        for second in 0 ..< SECOND_MAX {
            self.timeItem[2].append(second)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "count" {
            let viewController: ViewController = segue.destination as! ViewController
            let model: modelClass = sender as! modelClass
            viewController.id = model.id
            viewController.startDate = SKDateFormat.createDateTime(date: Date(),
                                                                   identifier: "ja_JP")
            if model.isStopped == .playing {
                viewController.deadline = model.end
            } else {
                viewController.deadline = viewController.startDate.addingTimeInterval(model.remainingTime)
            }
            viewController.status = model.isStopped
            viewController.initialRemainingTime = model.initialRemainingTime
            viewController.mode = 1
        }
    }
    
    @IBAction fileprivate func start() {
        self.performSegue(withIdentifier: "count",
                          sender: nil)
    }
    
    @IBAction fileprivate func changeMode(segmentControl: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.datePicker?.isHidden = false
            self.countDownPicker?.isHidden = true
        case 1:
            self.datePicker?.isHidden = true
            self.countDownPicker?.isHidden = false
        default:
            break
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timeItem[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%02d", self.timeItem[component][row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            self.selectedHour = self.timeItem[component][row]
            break
        case 1:
            self.selectedMinute = self.timeItem[component][row]
            break
        case 2:
            self.selectedSecond = self.timeItem[component][row]
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel?.text = modelArray[indexPath.row].text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "count",
                          sender: modelArray[indexPath.row])
    }
}

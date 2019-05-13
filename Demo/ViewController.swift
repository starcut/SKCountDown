//
//  ViewController.swift
//  Demo
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit
import SKCountDown

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    fileprivate var timeItem: [[Int]] = [[],[],[]]
    
    fileprivate let HOUR_MAX: Int = 24
    fileprivate let MINUTE_MAX: Int = 60
    fileprivate let SECOND_MAX: Int = 60
    
    fileprivate var selectedHour: Int = 0
    fileprivate var selectedMinute: Int = 0
    fileprivate var selectedSecond: Int = 0
    
    fileprivate var isStopped: Bool = true
    
    @IBOutlet private weak var countDownLabel: SKCountDownLabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var countDownPicker: UIPickerView!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var stopButton: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countDownPicker.delegate = self
        self.countDownPicker.dataSource = self
        
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
    
    @IBAction fileprivate func start() {
        self.isStopped = false
        if self.segmentControl.selectedSegmentIndex == 0 {
            self.countDownLabel.setDeadlineDate(selectedDate: self.datePicker.date,
                                                style: .full,
                                                identifier: self.datePicker.locale!.identifier)
        } else {
            self.countDownLabel.setDeadlineCountDown(hourAhead: selectedHour,
                                                     minuteAhead: selectedMinute,
                                                     secondAhead: selectedSecond,
                                                     style: .full,
                                                     identifier: self.datePicker.locale!.identifier)
        }
        
        self.countDownLabel.deadlineNearTime = 60
        self.countDownLabel.timeupString = "お疲れ様でした"
    }
    
    @IBAction fileprivate func switchMovingTimer() {
        self.isStopped = !self.isStopped
        if self.isStopped {
            self.stopButton.titleLabel?.text = "再開"
        } else {
            self.stopButton.titleLabel?.text = "一時停止"
        }
        self.countDownLabel.switchMovingTimer(isStopedTimer: self.isStopped)
    }
    
    @IBAction fileprivate func reset() {
        self.countDownLabel.resetTimer()
    }
    
    @IBAction fileprivate func changeMode(segmentControl: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.datePicker.isHidden = false
            self.countDownPicker.isHidden = true
        case 1:
            self.datePicker.isHidden = true
            self.countDownPicker.isHidden = false
        default:
            break
        }
    }
    
    @IBAction fileprivate func changeTimeStyle(button: UIButton) {
        switch button.tag {
        case 1:
            self.countDownLabel.timeStyle = .defaultStyle
        case 2:
            self.countDownLabel.timeStyle = .milliSecond
        case 3:
            self.countDownLabel.timeStyle = .second
        case 4:
            self.countDownLabel.timeStyle = .minute
        case 5:
            self.countDownLabel.timeStyle = .hour
        case 6:
            self.countDownLabel.timeStyle = .day
        case 7:
            self.countDownLabel.timeStyle = .month
        case 8:
            self.countDownLabel.timeStyle = .year
        case 9:
            self.countDownLabel.timeStyle = .full
        case 10:
            self.countDownLabel.timeStyle = .digital
        case 11:
            self.countDownLabel.timeStyle = .digitalFull
        default:
            self.countDownLabel.timeStyle = .milliSecond
        }
    }
}


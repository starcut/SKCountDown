//
//  ViewController.swift
//  Demo
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit
import SKCountDown
import AudioToolbox

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    fileprivate var timeItem: [[Int]] = [[],[],[]]
    
    fileprivate let HOUR_MAX: Int = 24
    fileprivate let MINUTE_MAX: Int = 60
    fileprivate let SECOND_MAX: Int = 60
    
    fileprivate var selectedHour: Int = 0
    fileprivate var selectedMinute: Int = 0
    fileprivate var selectedSecond: Int = 0
    
    @IBOutlet fileprivate weak var countDownLabel: SKCountDownLabel!
    @IBOutlet fileprivate weak var rateLabel: UILabel!
    @IBOutlet fileprivate weak var datePicker: UIDatePicker!
    @IBOutlet fileprivate weak var countDownPicker: UIPickerView!
    @IBOutlet fileprivate weak var segmentControl: UISegmentedControl!
    @IBOutlet fileprivate weak var stopButton: UIButton!
    
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
        if self.segmentControl.selectedSegmentIndex == 0 {
            self.countDownLabel.setDeadlineDate(startDate: SKDateFormat.createDateTime(date: .init(), identifier: "ja_JP"),
                                                deadline: self.datePicker.date,
                                                countDownMode: .deadlineMode,
                                                countDownStatus: .pause,
                                                style: .full,
                                                identifier: self.datePicker.locale!.identifier)
        } else {
            self.countDownLabel.setDeadlineCountDown(hourAhead: selectedHour,
                                                     minuteAhead: selectedMinute,
                                                     secondAhead: selectedSecond,
                                                     countDownMode: .timerMode,
                                                     style: .full,
                                                     identifier: self.datePicker.locale!.identifier)
        }
        
        self.countDownLabel.nearDeadlineTime = 60
        self.countDownLabel.timeupString = "お疲れ様でした"
        // 時間を更新のたびに行う処理
        self.countDownLabel.processInUpdatingTimer = {
            self.rateLabel.text = String(format: "%06.3f", self.countDownLabel.getProgressRate())
        }
        // 残り時間がnearDeadlineTimeを下回った時の処理
        self.countDownLabel.processInNearDeadline = {
            self.countDownLabel.textColor = .orange
            // 初回のバイブレーションを鳴らす
            AudioServicesPlaySystemSound(1011)
        }
        // 期日が来た時に行う処理
        self.countDownLabel.processInDeadline = {
            self.countDownLabel.textColor = .red
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    @IBAction fileprivate func switchMovingTimer() {
        // タイマーがスタートしていない場合は一時停止ボタンは動作させない
        if self.countDownLabel.getRemainingTime() <= 0 {
            return
        }
        
        self.countDownLabel.switchMovingTimer(completion: {(isStopped: CountDownStatus) in
            switch isStopped {
            case .playing:
                self.stopButton.setTitle("一時停止", for: .normal)
            case .pause:
                self.stopButton.setTitle("再開", for: .normal)
            case .stopped:
                return
            }
        })
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


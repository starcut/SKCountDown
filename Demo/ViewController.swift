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

class ViewController: UIViewController {
    fileprivate var selectedHour: Int = 0
    fileprivate var selectedMinute: Int = 0
    fileprivate var selectedSecond: Int = 0
    
    fileprivate let dateLocation: String = "ja_JP"
    
    public var id: Int = 0
    public var mode: Int = 0
    public var startDate: Date = Date()
    public var deadline: Date = Date()
    public var status: CountDownStatus = .stopped
    public var initialRemainingTime: Double = .zero
    
    @IBOutlet fileprivate weak var countDownLabel: SKCountDownLabel!
    @IBOutlet fileprivate weak var rateLabel: UILabel!
    @IBOutlet fileprivate weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.countDownLabel.setDeadlineDate(startDate: self.startDate,
                                            deadline: self.deadline,
                                            countDownMode: CountDownMode(rawValue: UInt(mode)) ?? .timerMode,
                                            countDownStatus: self.status,
                                            style: .full,
                                            identifier: self.dateLocation)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        modelArray[id].end = self.deadline
        modelArray[id].remainingTime = self.countDownLabel.getRemainingTime()
        modelArray[id].isStopped = self.countDownLabel.getCountDownStatus()
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


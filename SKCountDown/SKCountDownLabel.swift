//
//  SKCountDownLabel.swift
//  SKCountDown
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit

open class SKCountDownLabel: UILabel {
    fileprivate var deadline: Date = Date()
    // タイマー
    var timer : Timer!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setDeadline(deadline: Date) {
        self.deadline = deadline
        self.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: UIFont.systemFontSize)!
        self.text = String.init(format: "%.3f", floor(self.deadline.timeIntervalSinceNow * 1000) / 1000)
        self.updateTime()
    }
    
    func updateTime() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.001,
                                          target: self,
                                          selector: #selector(countDownDisplay),
                                          userInfo: nil,
                                          repeats: true
        )
    }
        
    @objc func countDownDisplay() { //(_ sender: Timer) Timerクラスのインスタンスを受け取る
        var remainingTime :Double = floor(self.deadline.timeIntervalSinceNow * 1000) / 1000
        if remainingTime < 0 {
            remainingTime = 0
            self.timer.invalidate()
        }
        
        self.text = String.init(format: "%.3f", remainingTime)
    }
}

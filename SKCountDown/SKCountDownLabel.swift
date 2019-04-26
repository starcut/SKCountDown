//
//  SKCountDownLabel.swift
//  SKCountDown
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit

public enum TimeStyle: UInt {
    case milliSecond = 0
    case second
    case minute
    case hour
    case day
    case month
    case year
    case full
    case defaultStyle
}

open class SKCountDownLabel: UILabel {
    // 年の文字列のフォーマット
    let STRING_FORMAT_YEAR: String = "%d年"
    // 月の文字列のフォーマット
    let STRING_FORMAT_MONTH: String = "%2dヶ月"
    // 日の文字列のフォーマット
    let STRING_FORMAT_DAY: String = "%2d日"
    // 時間の文字列のフォーマット
    let STRING_FORMAT_HOUR: String = "%2d時間"
    // 分の文字列のフォーマット
    let STRING_FORMAT_MINUTE: String = "%2d分"
    // 秒の文字列のフォーマット
    let STRING_FORMAT_SECONT: String = "%2d秒"
    // ミリ秒の文字列のフォーマット
    let STRING_FORMAT_MILLISECOND: String = "%02d.%03d秒"
    // 期日
    fileprivate var deadline: Date = Date()
    // タイマー
    fileprivate var timer : Timer!
    // 時間の表示形式
    open var timeStyle: TimeStyle = .defaultStyle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: self.font.pointSize)!
        self.adjustsFontSizeToFitWidth = true
        
        self.addObserver(self, forKeyPath: "timeStyle", options: [.new], context: nil)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeStyle" {
            self.text = self.setRemainingTime(deadline: self.deadline)
        }
    }
    
    public func setDeadline(deadline: Date, style: TimeStyle) {
        self.deadline = deadline
        self.timeStyle = style
        self.text = self.setRemainingTime(deadline: self.deadline)
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
        
    @objc func countDownDisplay() {
        var remainingTime :Double = floor(self.deadline.timeIntervalSinceNow * 1000) / 1000
        if remainingTime < 0 {
            remainingTime = 0
            self.timer.invalidate()
        }
        
        self.text = self.setRemainingTime(deadline: self.deadline)
    }
    
    fileprivate func setRemainingTime(deadline: Date) -> String {
        let remainingDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: Date(), to: deadline)
        
        let remainingMilliSecond: Double = floor(self.deadline.timeIntervalSinceNow * 1000) / 1000
        
        switch self.timeStyle {
        case .milliSecond:
            return String(format: "%.3f秒", remainingMilliSecond)
        case .second:
            return String(format: "%d秒", Int(floor(remainingMilliSecond)))
        case .minute:
            return String(format: "%d分", Int(floor(remainingMilliSecond) / 60))
        case .hour:
            return String(format: "%d時間", Int(floor(remainingMilliSecond) / 3600))
        case .day:
            return String(format: "%d日", Int(floor(remainingMilliSecond) / (3600 * 24)))
        case .month:
            return String(format: "%dヶ月", remainingDateComponents.month!)
        case .year:
            return String(format: STRING_FORMAT_YEAR, remainingDateComponents.year!)
        case .full:
            var remainingString: Substring = Substring()
            if remainingDateComponents.year! > 0 {
                remainingString.append(contentsOf: String(format: STRING_FORMAT_YEAR,
                                                          remainingDateComponents.year!))
            }
            if remainingDateComponents.month! > 0 ||
                (remainingDateComponents.month! == 0 && remainingDateComponents.year! > 0) {
                remainingString.append(contentsOf: String(format: STRING_FORMAT_MONTH,
                                                          remainingDateComponents.month!))
            }
            if remainingDateComponents.day! > 0 ||
                (remainingDateComponents.day! == 0 && remainingDateComponents.month! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_DAY,
                                                          remainingDateComponents.day!))
            }
            if remainingDateComponents.hour! > 0 ||
                (remainingDateComponents.hour! == 0 && remainingDateComponents.day! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_HOUR,
                                                          remainingDateComponents.hour!))
            }
            if remainingDateComponents.minute! > 0 ||
                (remainingDateComponents.minute! == 0 && remainingDateComponents.hour! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_MINUTE,
                                                          remainingDateComponents.minute!))
            }
            if remainingDateComponents.second! > 0 ||
                (remainingDateComponents.second! == 0 && remainingDateComponents.minute! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_MILLISECOND, remainingDateComponents.second!, remainingDateComponents.nanosecond! / 1000000))
            }
            return String(remainingString)
        case .defaultStyle:
            var remainingString: Substring = Substring()
            if remainingDateComponents.year! > 0 {
                remainingString.append(contentsOf: String(format: STRING_FORMAT_YEAR,
                                                          remainingDateComponents.year!))
            }
            if remainingDateComponents.month! > 0 ||
                (remainingDateComponents.month! == 0 && remainingDateComponents.year! > 0) {
                remainingString.append(contentsOf: String(format: STRING_FORMAT_MONTH,
                                                          remainingDateComponents.month!))
            }
            if remainingDateComponents.day! > 0 ||
                (remainingDateComponents.day! == 0 && remainingDateComponents.month! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_DAY,
                                                          remainingDateComponents.day!))
            }
            if remainingDateComponents.hour! > 0 ||
                (remainingDateComponents.hour! == 0 && remainingDateComponents.day! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_HOUR,
                                                          remainingDateComponents.hour!))
            }
            if remainingDateComponents.minute! > 0 ||
                (remainingDateComponents.minute! == 0 && remainingDateComponents.hour! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_MINUTE,
                                                          remainingDateComponents.minute!))
            }
            if remainingDateComponents.second! > 0 ||
                (remainingDateComponents.second! == 0 && remainingDateComponents.minute! > 0){
                remainingString.append(contentsOf: String(format: STRING_FORMAT_SECONT,
                                                          remainingDateComponents.second!))
            }
            return String(remainingString)
        }
    }
}

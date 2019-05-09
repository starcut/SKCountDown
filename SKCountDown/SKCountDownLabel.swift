//
//  SKCountDownLabel.swift
//  SKCountDown
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit

/** 表示する時間のスタイル */
public enum TimeStyle: UInt {
    case defaultStyle = 0   /** 残り時間を年数から秒までそれぞれの単位に分けて表示する */
    case milliSecond        /** 残り時間を秒単位で表示する（ミリ秒まで） */
    case second             /** 残り時間を秒単位で表示する（ミリ秒以下切り捨て） */
    case minute             /** 残り時間を分単位で表示する（秒以下切り捨て） */
    case hour               /** 残り時間を時間単位で表示する（分以下切り捨て） */
    case day                /** 残り日数を表示する（時間以下切り捨て） */
    case month              /** 残り月数を表示する（日数以下切り捨て） */
    case year               /** 残り年数を表示する（月数以下切り捨て） */
    case full               /** 残り時間を年数からミリ秒までそれぞれの単位を分けて表示する */
}

open class SKCountDownLabel: UILabel {
    /** 時間の表示形式 */
    open var timeStyle: TimeStyle = .defaultStyle
    /** 期日が来た時に表示する文字列 */
    open var timeupString: String = "時間切れ"
    /** 期日が近いと判定される残り時間 */
    open var deadlineNearTime: Double = 0
    /** 年の文字列のフォーマット */
    fileprivate let STRING_FORMAT_YEAR: String = "%d年"
    /** 月の文字列のフォーマット */
    fileprivate let STRING_FORMAT_MONTH: String = "%02dヶ月"
    /** 日の文字列のフォーマット */
    fileprivate let STRING_FORMAT_DAY: String = "%02d日"
    /** 時間の文字列のフォーマット */
    fileprivate let STRING_FORMAT_HOUR: String = "%02d時間"
    /** 分の文字列のフォーマット */
    fileprivate let STRING_FORMAT_MINUTE: String = "%02d分"
    /** 秒の文字列のフォーマット */
    fileprivate let STRING_FORMAT_SECONT: String = "%02d秒"
    /** ミリ秒の文字列のフォーマット */
    fileprivate let STRING_FORMAT_MILLISECOND: String = "%02d.%03d秒"
    /** 表示する時間のタイムインターバル */
    fileprivate let UPDATE_DEADLINE_TIME_INTERVAL: TimeInterval = 0.001
    /** 期日 */
    fileprivate var deadline: Date = .init()
    /** タイマー */
    fileprivate var timer: Timer!
    /** 残り時間 */
    fileprivate var milliSecond: Double = 0
    
    // -------------------------------------------------------
    // MARK: Override Method
    // -------------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    /**
     * 指定された値が変更された時に呼ばれる処理
     */
    override open func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        // 表示時間のスタイルが変更されたらスタイルを変更して再表示を行う
        if keyPath == "timeStyle" {
            self.setRemainingTime()
        }
    }
    
    // -------------------------------------------------------
    // MARK: Public Method
    // -------------------------------------------------------
    /**
     * 日時指定形式での期日設定
     *
     * - Parameters:
     *   - selectedDate:    期日の文字列
     *   - style:           時間の表示スタイル
     *   - identifier:      地域の識別子
     */
    public func setDeadlineDate(selectedDate: Date,
                                style: TimeStyle,
                                identifier: String) {
        self.commonInit()
        
        let deadline: Date = SKDateFormat.createDateTime(date: selectedDate,
                                                         identifier: identifier)
        // Stringに変換した日付を使って期限設定
        self.setDeadline(deadline: deadline, style: style)
    }
    
    /**
     * カウントダウン形式での期日設定
     *
     * - Parameters:
     *   - hourAhead:   現時刻から何時間先か
     *   - minuteAhead: 現時刻から何分先か
     *   - secondAhead: 現時刻から何秒先か
     *   - style:       時間の表示スタイル
     *   - identifier:  地域の識別子
     */
    public func setDeadlineCountDown(hourAhead: Int,
                                     minuteAhead: Int,
                                     secondAhead: Int,
                                     style: TimeStyle,
                                     identifier: String) {
        self.commonInit()
        
        let aheadTime: Date = SKDateFormat.getTimeAhead(hourAhead: hourAhead,
                                                        minuteAhead: minuteAhead,
                                                        secondAhead: secondAhead,
                                                        since: .init())
        let deadline: Date = SKDateFormat.createDateTime(date: aheadTime,
                                                         identifier: identifier)
        self.setDeadline(deadline: deadline, style: .full)
    }
    
    /**
     * 残り時間を取得する
     * - Returns:   残り時間（単位は秒）
     */
    public func getRemainingTime() -> Double {
        return self.milliSecond
    }
    
    // -------------------------------------------------------
    // MARK: File Private Method
    // -------------------------------------------------------
    /**
     * 共通の初期化事項
     */
    fileprivate func commonInit() {
        if self.timer != nil {
            self.timer.invalidate()
        }
        
        self.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: self.font.pointSize)!
        self.adjustsFontSizeToFitWidth = true
        self.textColor = .black
        
        if self.observationInfo != nil {
            self.removeObserver(self, forKeyPath: "timeStyle")
        }
        self.addObserver(self, forKeyPath: "timeStyle", options: [.new], context: nil)
    }
    
    /**
     * 期日、時間の表示スタイルをセットし、カウントダウンを開始する
     *
     * - Parameters:
     *   - deadline:    期日
     *   - style:       時間の表示スタイル
     */
    fileprivate func setDeadline(deadline: Date, style: TimeStyle) {
        self.deadline = deadline
        self.timeStyle = style
        self.timer = Timer.scheduledTimer(timeInterval: UPDATE_DEADLINE_TIME_INTERVAL,
                                          target: self,
                                          selector: #selector(setRemainingTime),
                                          userInfo: nil,
                                          repeats: true
        )
    }
    
    /**
     * 残り時間をスタイルに応じて表示する
     */
    @objc fileprivate func setRemainingTime() {
        self.milliSecond = floor(self.deadline.timeIntervalSinceNow * 1000) / 1000
        
        // 期日がきた場合はタイマーを止め、時間切れの表示をし処理を終える
        if self.milliSecond < 0 {
            self.milliSecond = 0
            self.timer.invalidate()
            self.text = self.timeupString
            return
        }
        
        // 残り時間が少なくなったら赤文字表示
        if self.milliSecond <= self.deadlineNearTime {
            self.textColor = .red
        }
        
        // 今から期日までの年数などを取得
        let components: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond],
                                                                         from: Date(),
                                                                         to: self.deadline)
        switch self.timeStyle {
        case .milliSecond:
            self.text = String(format: "%.3f秒", self.milliSecond)
            break
        case .second:
            self.text = String(format: "%d秒", Int(floor(self.milliSecond)))
            break
        case .minute:
            self.text = self.displayIncludeLessThan(remainingTime: Int(floor(self.milliSecond) / 60),
                                                    timeStyle: .minute,
                                                    milliSecond: self.milliSecond)
            break
        case .hour:
            self.text = self.displayIncludeLessThan(remainingTime: Int(floor(self.milliSecond) / 3600),
                                                    timeStyle: .hour,
                                                    milliSecond: self.milliSecond)
            break
        case .day:
            self.text = self.displayIncludeLessThan(remainingTime: Int(floor(self.milliSecond) / (3600 * 24)),
                                                    timeStyle: .day,
                                                    milliSecond: self.milliSecond)
            break
        case .month:
            self.text = self.displayIncludeLessThan(remainingTime: components.month! + 12 * components.year!,
                                                    timeStyle: .month,
                                                    milliSecond: self.milliSecond)
            break
        case .year:
            self.text = self.displayIncludeLessThan(remainingTime: components.year!,
                                                    timeStyle: .year,
                                                    milliSecond: self.milliSecond)
            break
        case .full:
            var remainingString: Substring = self.createDateTimeStringFromYearToMinute(diffDateComponents: components)
            remainingString.append(contentsOf: String(format: STRING_FORMAT_MILLISECOND,
                                                      components.second!,
                                                      components.nanosecond! / 1000000))
            self.text = String(remainingString)
            break
        case .defaultStyle:
            var remainingString: Substring = self.createDateTimeStringFromYearToMinute(diffDateComponents: components)
            remainingString.append(contentsOf: String(format: STRING_FORMAT_SECONT,
                                                      components.second!))
            self.text = String(remainingString)
            break
        }
    }
    
    /**
     * 単位に応じた期日までの時間を表す。
     * 指定した単位が0でも期日まで時間が残っている場合は「未満」という表示をする
     * 例：あと50秒のところで残り時間を「分単位」で表示→「1分未満」
     *
     * - Parameters:
     *   - remainingTime:   期日までのそれぞれの単位
     *   - timeStyle:       時間の表示スタイル
     *   - milliSecond:     ミリ秒単位で表したの残り時間
     * - Returns:           指定した単位で表される残り時間
     */
    fileprivate func displayIncludeLessThan(remainingTime: Int,
                                            timeStyle: TimeStyle,
                                            milliSecond: Double) -> String {
        var unitString: String = ""
        
        switch timeStyle {
        case .minute:
            unitString = "分"
            break
        case .hour:
            unitString = "時間"
            break
        case .day:
            unitString = "日"
            break
        case .month:
            unitString = "ヶ月"
            break
        case .year:
            unitString = "年"
            break
        default:
            break
        }
        
        if remainingTime == 0 && milliSecond > 0 {
            return "1\(unitString)未満"
        }
        return String(format: "%d\(unitString)", remainingTime)
    }
    
    /**
     * 期日までの残りの「年数」から「分」までそれぞれの単位に分けて表示する
     *
     * - Parameters:
     *   - diffDateComponents:  現時刻から期日までの差
     * - Returns:               残り時間の文字列
     */
    fileprivate func createDateTimeStringFromYearToMinute(diffDateComponents: DateComponents) -> Substring{
        var remainingString: Substring = Substring()
        remainingString = self.appendRemainingDateString(remainingDateTime: diffDateComponents.year!,
                                                         StringFormat: STRING_FORMAT_YEAR,
                                                         remainingDateString: remainingString)
        remainingString = self.appendRemainingDateString(remainingDateTime: diffDateComponents.month!,
                                                         StringFormat: STRING_FORMAT_MONTH,
                                                         remainingDateString: remainingString)
        remainingString = self.appendRemainingDateString(remainingDateTime: diffDateComponents.day!,
                                                         StringFormat: STRING_FORMAT_DAY,
                                                         remainingDateString: remainingString)
        remainingString = self.appendRemainingDateString(remainingDateTime: diffDateComponents.hour!,
                                                         StringFormat: STRING_FORMAT_HOUR,
                                                         remainingDateString: remainingString)
        remainingString = self.appendRemainingDateString(remainingDateTime: diffDateComponents.minute!,
                                                         StringFormat: STRING_FORMAT_MINUTE,
                                                         remainingDateString: remainingString)
        return remainingString
    }
    
    /**
     * 指定の単位の残り時間の文字連結を行う。
     * ただし、その単位の残り時間が0で、なおかつその単位より大きい単位の値が0の場合は文字列を表示しない
     * 例：残り0年0ヶ月3日（「時間」以下略）の場合、「3日（「時間」以下略）」と表示する
     *
     * - Parameters:
     *   - remainingDateTime:   指定した単位までの期日までの値
     *   - StringFormat:        文字列のgフォーマット
     *   - remainingDateString: 現時点までの処理で作成されている残り日時の文字列
     * - Returns:               指定した単位で表される時間の文字列
     */
    fileprivate func appendRemainingDateString(remainingDateTime: Int,
                                               StringFormat: String,
                                               remainingDateString: Substring) -> Substring {
        var subString: Substring = remainingDateString
        if remainingDateTime > 0 || remainingDateString.count > 0 {
            subString.append(contentsOf: String(format: StringFormat, remainingDateTime))
        }
        return subString
    }
}

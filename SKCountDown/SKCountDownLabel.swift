//
//  SKCountDownLabel.swift
//  SKCountDown
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit
import AudioToolbox

/** 表示する時間のスタイル */
public enum TimeStyle: UInt {
    case defaultStyle = 0       /** 残り時間を年数から秒までそれぞれの単位に分けて表示する */
    case milliSecond            /** 残り時間を秒単位で表示する（ミリ秒まで） */
    case second                 /** 残り時間を秒単位で表示する（ミリ秒以下切り捨て） */
    case minute                 /** 残り時間を分単位で表示する（秒以下切り捨て） */
    case hour                   /** 残り時間を時間単位で表示する（分以下切り捨て） */
    case day                    /** 残り日数を表示する（時間以下切り捨て） */
    case month                  /** 残り月数を表示する（日数以下切り捨て） */
    case year                   /** 残り年数を表示する（月数以下切り捨て） */
    case full                   /** 残り時間を年数からミリ秒までそれぞれの単位を分けて表示する */
    case digital                /** YY/MM/dd HH:mm:ssの形式で表示する */
    case digitalFull            /** YY/MM/dd HH:mm:ss.SSSの形式で表示する */
}

/** カウントダウンの種類 */
public enum CountDownMode: UInt {
    case deadlineMode = 0   /** 期日指定のカウントダウンモード */
    case timerMode          /** タイマー形式のカウントダウンモード */
}

/** カウントダウンの状態 */
public enum CountDownStatus: UInt {
    case playing = 0        /** タイマーが動いている状態 */
    case pause              /** タイマーが一時停止している状態 */
    case stopped            /** タイマーが止まっている状態 */
}

/** エラーメッセージ */
fileprivate enum ErrorText: String {
    case canUseOnlyTimerMode = "タイマーモードでのみ表示可能"
}

open class SKCountDownLabel: UILabel {
    /** 時間の表示形式 */
    open var timeStyle: TimeStyle = .defaultStyle {
        didSet {
            self.updateTimeDisplay()
        }
    }
    /** 期日が来た時に表示する文字列 */
    open var timeupString: String = "時間切れ"
    /** 期日が近いと判定される残り時間 */
    open var nearDeadlineTime: Double = 0
    /** タイマーを更新する時に行う処理 */
    open var processInUpdatingTimer:(() -> Void)?
    /** 残り時間が指定した時間を下回った場合に一度だけ行う処理 */
    open var processInNearDeadline:(() -> Void)?
    /** 時間切れになった時に行う処理 */
    open var processInDeadline:(() -> Void)?
    
    /** ミリ秒まで含めた秒のみ文字列のフォーマット */
    fileprivate let STRING_FORMAT_ONLY_MILLISECOND: String = "%.3f秒"
    /** 秒のみ文字列のフォーマット */
    fileprivate let STRING_FORMAT_ONLY_SECOND: String = "%02d秒"
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
    fileprivate let STRING_FORMAT_SECOND: String = "%02d秒"
    /** ミリ秒の文字列のフォーマット */
    fileprivate let STRING_FORMAT_MILLISECOND: String = "%02d.%03d秒"
    /** タイマー形式のフォーマット */
    fileprivate let STRING_FORMAT_SECOND_DIGITAL: String = "%02d:%02d:%02d"
    /** ミリ秒まで含めたタイマー形式のフォーマット */
    fileprivate let STRING_FORMAT_MILLISECOND_DIGITAL: String = "%02d:%02d:%02d.%03d"
    /** タイマー形式の日時を表示するフォーマット */
    fileprivate let STRING_FORMAT_DIGITAL_DATE_TIME: String = "%02d/%02d/%02d %02d:%02d:%02d"
    /** タイマー形式のミリ秒まで含めた日時を表示するフォーマット */
    fileprivate let STRING_FORMAT_DIGITAL_DATE_TIME_FULL: String = "%02d/%02d/%02d %02d:%02d:%02d.%03d"
    /** 表示する時間のタイムインターバル */
    fileprivate let UPDATE_DEADLINE_TIME_INTERVAL: TimeInterval = 0.001
    /** タイマーが止まっているかどうか */
    fileprivate(set) var countDownStatus: CountDownStatus = .stopped
    /** 開始日時 */
    fileprivate var startDate: Date = .init()
    /** 期日 */
    fileprivate var deadline: Date = .init()
    /** 初期状態の残り時間 */
    fileprivate var initialRemainingTime: Double = 0
    /** タイマー */
    fileprivate var timer: Timer!
    /** 残り時間 */
    fileprivate(set) var milliSecond: Double = .zero {
        didSet {
            self.updateTimeDisplay()
        }
    }
    /** カウントダウンの形式 */
    fileprivate(set) var countDownMode: CountDownMode = .deadlineMode
    
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
        if self.countDownStatus != .stopped {
            return
        }
        
        self.commonInit()
        
        self.countDownMode = .deadlineMode
        // Stringに変換した日付を使って期限設定
        self.startCountDown(deadline: selectedDate,
                            style: style,
                            identifier: identifier)
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
                                     countDownMode: CountDownMode,
                                     style: TimeStyle,
                                     identifier: String) {
        if self.countDownStatus != .stopped {
            return
        }
        
        self.commonInit()
        
        self.countDownMode = countDownMode
        
        let MINUTE_MAX: Int = 60
        let SECOND_MAX: Int = 60
        var addTime: Int = hourAhead * MINUTE_MAX * SECOND_MAX
        addTime += minuteAhead * SECOND_MAX
        addTime += secondAhead
        
        // Stringに変換した日付を使って期限設定
        let deadlineTemp = Date(timeInterval: TimeInterval(addTime),
                                since: .init())
        self.startCountDown(deadline: deadlineTemp,
                            style: style,
                            identifier: identifier)
    }
    
    /**
     * カウントダウンの一時停止、再開を切り替える
     * ただし、日付指定のカウントダウンの場合はこのメソッドは無効
     *
     * - Parameters:
     *   - isStopedTimer:   タイマーが止まっているかどうか
     */
    public func switchMovingTimer(completion:(CountDownStatus) -> ()) {
        // 残り時間が0、つまりタイマーをセットしていない場合は一時停止の切り替えさせない
        if self.milliSecond <= 0 {
            self.timer.invalidate()
            return
        }
        
        // タイマーモードでない場合は一時停止させない
        if self.countDownMode != .timerMode {
            return
        }
        
        switch self.countDownStatus {
        case .playing:
            // 一時停止状態にする
            self.countDownStatus = .pause
            self.timer.invalidate()
        default:
            // 停止状態から動作状態にする
            self.countDownStatus = .playing
            self.deadline = Date().addingTimeInterval(self.milliSecond)
            self.timer = Timer.scheduledTimer(timeInterval: UPDATE_DEADLINE_TIME_INTERVAL,
                                              target: self,
                                              selector: #selector(updateRemainingTime),
                                              userInfo: nil,
                                              repeats: true)
        }
        completion(self.countDownStatus)
    }
    
    /**
     * タイマーをリセットする
     */
    public func resetTimer() {
        switch self.countDownMode {
        case .deadlineMode:
            self.commonInit()
        case .timerMode:
            self.timer.invalidate()
            self.countDownStatus = .stopped
            self.milliSecond = self.initialRemainingTime
            self.startDate = SKDateFormat.createDateTime(date: .init(), identifier: "ja_JP")
            self.deadline = self.startDate.addingTimeInterval(self.initialRemainingTime)
            self.updateTimeDisplay()
        }
        
    }
    
    /**
     * 残り時間を取得する
     * - Returns:   残り時間（単位は秒）
     */
    public func getRemainingTime() -> Double {
        return self.milliSecond
    }
    
    /**
     * 現在タイマーのタイマーの動作状態を取得する
     * - Returns:   タイマーが止まっているかどうか
     */
    public func getCountDownStatus() -> CountDownStatus {
        return self.countDownStatus
    }
    
    /**
     * 残り時間の割合を取得する
     *
     * - Returns:   残り時間の割合[％]
     */
    public func getProgressRate() -> Double {
        return (1 - (self.milliSecond / self.initialRemainingTime)) * 100
    }
    
    // -------------------------------------------------------
    // MARK: File Private Method
    // -------------------------------------------------------
    /**
     * 共通の初期化事項
     */
    fileprivate func commonInit() {
        self.countDownStatus = .stopped
        
        self.milliSecond = .zero
        self.deadline = .init()
        
        self.text = self.changeTimeStyle()
        
        if self.timer != nil {
            self.timer.invalidate()
        }
        
        self.processInUpdatingTimer = nil
        self.processInNearDeadline = {
            self.textColor = .red
            AudioServicesPlaySystemSound(1102)
        }
        self.processInDeadline = {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        self.adjustsFontSizeToFitWidth = true
        self.textColor = .black
    }
    
    /**
     * 期日を設定してカウントダウンを開始する
     *
     * - Parameters:
     *   - deadline:    期日
     *   - style:       時間の表示スタイル
     *   - identifier:  地域の識別子
     */
    fileprivate func startCountDown(deadline: Date,
                                    style: TimeStyle,
                                    identifier: String) {
        self.startDate = SKDateFormat.createDateTime(date: .init(), identifier: identifier)
        self.deadline = SKDateFormat.createDateTime(date: deadline, identifier: identifier)
        self.initialRemainingTime = self.deadline.timeIntervalSince(self.startDate)
        // 期日が過去の日時だった場合、カウントダウンさせない
        if self.isSettedPast(date: self.deadline) {
            self.initialRemainingTime = 0
            return
        }
        self.countDownStatus = .playing
        self.timeStyle = style
        self.timer = Timer.scheduledTimer(timeInterval: UPDATE_DEADLINE_TIME_INTERVAL,
                                          target: self,
                                          selector: #selector(updateRemainingTime),
                                          userInfo: nil,
                                          repeats: true
        )
    }
    
    /**
     * 指定した日時が過去かどうか
     *
     * - Parameters:
     *   - date:    過去の日付か判定する上で基準となる日時
     * - Returns:   過去の日付かどうか
     */
    fileprivate func isSettedPast(date: Date) -> Bool {
        return self.deadline.compare(.init()) == .orderedAscending ||
               self.deadline.compare(.init()) == .orderedSame
    }
    
    /**
     * 残り時間を更新する
     */
    @objc fileprivate func updateRemainingTime() {
        self.milliSecond = floor(self.deadline.timeIntervalSinceNow * 1000) / 1000
    }
    
    /**
     * 残り時間を設定したスタイルに応じて表示する
     */
    fileprivate func updateTimeDisplay() {
        // 期日がきた場合はタイマーを止め、時間切れの表示をし処理を終える
        if self.milliSecond < 0 {
            self.milliSecond = 0
            self.switchMovingTimer(completion: {_ in })
            self.text = self.timeupString
            self.processInDeadline?()
            return
        }
        // タイマーが動いていない場合、時間の表示形式だけ変更して処理を中断する
        if self.isSettedPast(date: self.deadline) {
            self.deadline = .init()
            self.text = self.changeTimeStyle()
            return
        }
        
        if self.milliSecond < self.nearDeadlineTime && self.milliSecond > 0 {
            self.processInNearDeadline?()
            self.processInNearDeadline = nil
        }
        
        self.text = self.changeTimeStyle()
        self.processInUpdatingTimer?()
    }
    
    /**
     * 残り時間の表示形式を変える
     *
     * - Returns:   timeStyleに応じた残り時間の文字列
     */
    fileprivate func changeTimeStyle() -> String {
        // 今から期日までの年数などを取得
        let toDate: Date = SKDateFormat.createDateTime(date: self.deadline,
                                                       identifier: "ja_JP")
        let fromDate: Date = SKDateFormat.createDateTime(date: toDate.addingTimeInterval(-self.milliSecond),
                                                         identifier: "ja_JP")
        
        let components: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond],
                                                                         from: fromDate,
                                                                         to: toDate)
        switch self.timeStyle {
        case .defaultStyle:
            var remainingString: Substring = self.createDateTimeStringFromYearToMinute(diffDateComponents: components)
            remainingString.append(contentsOf: String(format: STRING_FORMAT_SECOND,
                                                      components.second!))
            return String(remainingString)
        case .milliSecond:
            return String(format: STRING_FORMAT_ONLY_MILLISECOND, self.milliSecond)
        case .second:
            return String(format: STRING_FORMAT_ONLY_SECOND, Int(self.milliSecond))
        case .minute:
            return self.displayIncludeLessThan(remainingTime: Int(self.milliSecond / 60),
                                               timeStyle: .minute,
                                               milliSecond: self.milliSecond)
        case .hour:
            return self.displayIncludeLessThan(remainingTime: Int(self.milliSecond / 3600),
                                               timeStyle: .hour,
                                               milliSecond: self.milliSecond)
        case .day:
            return self.displayIncludeLessThan(remainingTime: Int(self.milliSecond / (3600 * 24)),
                                               timeStyle: .day,
                                               milliSecond: self.milliSecond)
        case .month:
            return self.displayIncludeLessThan(remainingTime: components.month! + 12 * components.year!,
                                               timeStyle: .month,
                                               milliSecond: self.milliSecond)
        case .year:
            return self.displayIncludeLessThan(remainingTime: components.year!,
                                               timeStyle: .year,
                                               milliSecond: self.milliSecond)
        case .full:
            var remainingString: Substring = self.createDateTimeStringFromYearToMinute(diffDateComponents: components)
            remainingString.append(contentsOf: String(format: STRING_FORMAT_MILLISECOND,
                                                      components.second!,
                                                      components.nanosecond! / 1000000))
            return String(remainingString)
        case .digital:
            if self.isLessThanDay(diffDateComponents: components) {
                return String(format: STRING_FORMAT_SECOND_DIGITAL,
                              components.hour!,
                              components.minute!,
                              components.second!)
            }
            return String(format: STRING_FORMAT_DIGITAL_DATE_TIME,
                          components.year!,
                          components.month!,
                          components.day!,
                          components.hour!,
                          components.minute!,
                          components.second!)
        case .digitalFull:
            if self.isLessThanDay(diffDateComponents: components) {
                return String(format: STRING_FORMAT_MILLISECOND_DIGITAL,
                              components.hour!,
                              components.minute!,
                              components.second!,
                              components.nanosecond! / 1000000)
            }
            return String(format: STRING_FORMAT_DIGITAL_DATE_TIME_FULL,
                          components.year!,
                          components.month!,
                          components.day!,
                          components.hour!,
                          components.minute!,
                          components.second!,
                          components.nanosecond! / 1000000)
        }
    }
    
    /**
     * 残り時間が1日あるかチェックする
     *
     * - Returns:   残り時間が1日以上あるかどうか
     */
    fileprivate func isLessThanDay(diffDateComponents: DateComponents) -> Bool {
        return (diffDateComponents.year! == 0 && diffDateComponents.month! == 0 && diffDateComponents.day! == 0)
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
     *   - StringFormat:        文字列のフォーマット
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

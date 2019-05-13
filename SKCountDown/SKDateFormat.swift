//
//  SKDateFormat.swift
//  SKCountDown
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit

open class SKDateFormat: NSObject {
    /**
     * Dateから日時の文字列を取得する
     *
     * - Parameters:
     *   - date:        日付
     *   - identifier:  地域の識別子
     * - Returns:       dateの日時を格納した文字列
     */
    public static func createDateTimeString(date: Date, identifier: String) -> String {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY/MM/dd HH:mm:ss.SSS",
                                                        options: 0,
                                                        locale: Locale(identifier: identifier))
        return formatter.string(from: date)
    }
    
    /**
     * フォーマットを指定したDate型日付を取得する
     *
     * - Parameters:
     *   - date:        日付
     *   - identifier:  地域の識別子
     * - Returns:       フォーマット指定した日付
     */
    public static func createDateTime(date: Date, identifier: String) -> Date {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY/MM/dd HH:mm:ss.SSS",
                                                        options: 0,
                                                        locale: Locale(identifier: identifier))
        return formatter.date(from: formatter.string(from: date))!
    }
    
    /**
     * 文字列からDate型の時刻を取得する
     *
     * - Parameters:
     *   - date:        日付
     *   - identifier:  地域の識別子
     * - Returns:       dateの時間を格納したDate型オブジェクト
     */
    public static func createDateTimeByString(string: String, identifier: String) -> Date {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY/MM/dd HH:mm:ss.SSS",
                                                        options: 0,
                                                        locale: Locale(identifier: identifier))
        return formatter.date(from: string)!
    }
    
    /**
     * 基準となる時間から指定した分だけ先の時間を返す
     *
     * - Parameters:
     *   - hourAhead:   基準となる時刻から何時間先か
     *   - minuteAhead: 基準となる時刻から何分先か
     *   - secondAhead: 基準となる時刻から何秒先か
     *   - since:       基準となる時刻
     * - Returns:       dateの時間を格納したDate型オブジェクト
     */
    public static func getTimeAhead(hourAhead: Int, minuteAhead: Int, secondAhead: Int, since: Date) -> Date {
        let MINUTE_MAX: Int = 60
        let SECOND_MAX: Int = 60
        var timeAhead: Int = hourAhead * MINUTE_MAX * SECOND_MAX
        timeAhead += minuteAhead * SECOND_MAX
        timeAhead += secondAhead
        return .init(timeInterval: TimeInterval(timeAhead), since: since)
    }
}

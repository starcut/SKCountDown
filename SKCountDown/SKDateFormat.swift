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
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY/MM/dd HH:mm",
                                                        options: 0,
                                                        locale: Locale(identifier: identifier))
        return formatter.string(from: date)
    }
    
    /**
     * 文字列からDate型の時刻を取得する
     *
     * - Parameters:
     *   - date:        日付
     *   - identifier:  地域の識別子
     * - Returns:       dateの時間を格納したDate型オブジェクト
     */
    public static func createTime(string: String, identifier: String) -> Date {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY/MM/dd HH:mm",
                                                        options: 0,
                                                        locale: Locale(identifier: identifier))
        return formatter.date(from: string)!
    }
}

//
//  UtilTime.swift
//  SKCountDown
//
//  Created by 清水 脩輔 on 2019/05/28.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit

open class UtilTime: NSObject {
    /**
     * HH:mm:ss形式の文字列を単位の数値に変換する
     *
     */
    public static func isTimeStyle(timeString: String) -> Bool {
        let pattern: String = "^\\d{2}:\\d{2}:\\d{2}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let matches = regex.matches(in: timeString, range: NSRange(location: 0, length: timeString.count))
        return matches.count > 0
    }
    
    /**
     * HH:mm:ss形式の文字列を単位の数値に変換する
     *
     */
    public static func transformStringToSecond(timeString: String) -> Double {
        if !UtilTime.isTimeStyle(timeString: timeString) {
            return 0.0
        }
        
        let timeArray: [Substring] = timeString.split(separator: ":")
        let hour: Double = Double(timeArray[0]) ?? 0
        let minute: Double = Double(timeArray[1]) ?? 0
        let second: Double = Double(timeArray[2]) ?? 0
        return (hour*60*60) + (minute*60) + second
    }
}

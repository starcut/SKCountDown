//
//  SKCountDownModel.swift
//  Demo
//
//  Created by 清水 脩輔 on 2019/05/31.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit

open class SKCountDownModel: NSObject {
    open var id: Int = 0
    open var title: String = ""
    open var deadline: Date = Date()
    open var milliSecond: Double = .zero
    open var initialMilliSecond: Double = .zero
    open var style: TimeStyle = .full
    open var mode: CountDownMode = .timerMode
    open var status: CountDownStatus = .playing
    
    override init() {
        super.init()
    }
    
    public init(id: Int,
         title: String,
         deadline: Date,
         milliSecond: Double,
         initialMilliSecond: Double,
         style: TimeStyle,
         mode: CountDownMode,
         status: CountDownStatus) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.milliSecond = milliSecond
        self.initialMilliSecond = initialMilliSecond
        self.style = style
        self.mode = mode
        self.status = status
        
        super.init()
    }
}

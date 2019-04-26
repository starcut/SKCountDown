//
//  ViewController.swift
//  Demo
//
//  Created by 清水 脩輔 on 2019/04/25.
//  Copyright © 2019 清水 脩輔. All rights reserved.
//

import UIKit
import SKCountDown

class ViewController: UIViewController {
    @IBOutlet private weak var countDownLabel: SKCountDownLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.countDownLabel.setDeadline(deadline: SKDateFormat.createTime(string: "2019/05/01 00:00:00", identifier: "ja_JP"), style: .full)
    }

    @IBAction fileprivate func changeTimeStyle(button: UIButton) {
        switch button.tag {
        case 1:
            self.countDownLabel.timeStyle = .milliSecond
        case 2:
            self.countDownLabel.timeStyle = .second
        case 3:
            self.countDownLabel.timeStyle = .minute
        case 4:
            self.countDownLabel.timeStyle = .hour
        case 5:
            self.countDownLabel.timeStyle = .day
        case 6:
            self.countDownLabel.timeStyle = .month
        case 7:
            self.countDownLabel.timeStyle = .year
        case 8:
            self.countDownLabel.timeStyle = .full
        case 9:
            self.countDownLabel.timeStyle = .defaultStyle
        default:
            self.countDownLabel.timeStyle = .milliSecond
        }
    }
}


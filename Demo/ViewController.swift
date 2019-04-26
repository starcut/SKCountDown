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


}


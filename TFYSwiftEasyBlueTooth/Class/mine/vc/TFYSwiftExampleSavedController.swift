//
//  TFYSwiftExampleSavedController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/16.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftExampleSavedController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "本地保存设备"
    }
    
    var bleManager:TFYSwIFTEasyBlueToothManager? {
        didSet {
            let mange = bleManager
            if mange != nil {
                
            }
        }
    }

}

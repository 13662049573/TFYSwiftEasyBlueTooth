//
//  TFYSwiftExampleScanNameController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/16.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftExampleScanNameController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "名字";
    }
    

    var bleManager:TFYSwIFTEasyBlueToothManager? {
        didSet {
            let mange = bleManager
            if mange != nil {
                
            }
        }
    }
    

}

//
//  TFYSwiftMineController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftMineController: UIViewController {

    private lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect.zero, style: .grouped)
        tab.showsHorizontalScrollIndicator = false
        tab.contentInsetAdjustmentBehavior = .never
        tab.rowHeight = 80
        tab.estimatedSectionFooterHeight = 0.01
        tab.estimatedSectionHeaderHeight = 0.01
        tab.backgroundColor = .white
        tab.delegate = self
        tab.dataSource = self
        return tab
    }()
    
    private lazy var bleManager: TFYSwIFTEasyBlueToothManager = {
        let manage = TFYSwIFTEasyBlueToothManager.shareInstance
        let options:TFYSwiftEasyManagerOptions = TFYSwiftEasyManagerOptions(queue: DispatchQueue.main)
        options.scanTimeOut = 6
        options.connectTimeOut = 10
        options.autoConnectAfterDisconnect = true
        manage.managerOptions = options
        return manage
    }()
    
    private var dataArray:[String] = ["指定名称连接设备","一行代码连接设备","条件扫描设备名称"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "蓝牙方法演示"
        
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension TFYSwiftMineController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let withIdentifier:String = "\(String(format: "%ld", indexPath.row))"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: withIdentifier)
        if cell == nil {
            cell = TFYSwiftMineTableViewCell(style: .subtitle, reuseIdentifier: withIdentifier)
        }
        (cell as! TFYSwiftMineTableViewCell).title = dataArray[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc:TFYSwiftExampleScanNameController = TFYSwiftExampleScanNameController()
            vc.hidesBottomBarWhenPushed = true
            vc.bleManager = bleManager
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            self.bleManager.connectDeviceWithIdentifier(identifier: "5E40E1BC-732E-042E-7C56-9F89D59FB0E8") { peripheral, error in
                print("连接成功设备==============name:\(String(describing: peripheral?.name))")
            }
        } else if indexPath.row == 2 {
            self.bleManager.scanAllDeviceWithRule { peripheral in
                var namebool:Bool = false
                if peripheral.name != nil {
                    if peripheral.name!.hasPrefix("BLE-") {
                        namebool = true
                    }
                }
                return namebool
            } callback: { deviceArray, error in
                deviceArray.forEach { per in
                    print("name=====:\(String(describing: per.name))")
                }
                print("deviceArray=====\(deviceArray.count)")
            }
        }
    }
    
}

//
//  TFYSwiftExampleScanNameController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/16.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit
import TFYProgressSwiftHUD

let UUID_SERVICE:String = "0000FFF0-0000-1000-8000-00805F9B34FB"
let UUID_WRITE:String = "0000FFF1-0000-1000-8000-00805F9B34FB"
let UUID_NOTIFICATION:String = "0000FFF1-0000-1000-8000-00805F9B34FB"
let UUID_READ:String = "00002902-0000-1000-8000-00805f9b34fb"

class TFYSwiftExampleScanNameController: UIViewController {

    private var data:TFYSwIFTEasyBlueToothManager?
    private var peripheral:TFYSwiftEasyPeripheral?
    private var dataArr:[String] = ["APP设定时间","APP设定单位","APP同意连接","APP请求同步-APP读取记忆","APP同步成功-APP读取成功","读取实时温度","读取数据","监听数据","取消监听"]
    private lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect.zero, style: .plain)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "扫描设备名称";
        
        view.addSubview(tableView)
        
        data!.bluetoothStateChanged = { per , state in
            TFYSwiftAsynce.async {
            } _: {
                switch state {
                case .bluetoothStateSystemReadly:
                    TFYProgressSwiftHUD.showSucceed("蓝牙已准备就绪..")
                    break
                case .bluetoothStateDeviceFounded:
                    TFYProgressSwiftHUD.showError("已发现设备")
                    break
                case .bluetoothStateDeviceConnected:
                    TFYProgressSwiftHUD.showSucceed("设备连成功")
                    self.tableView.reloadData()
                    break
                default:
                    print("==============================:\(state)")
                    break
                }
            }
        }
        
        TFYProgressSwiftHUD.show("正在扫描并连接设别...")
        data?.scanAndConnectDeviceWithName(name: "BLE-GUC2_9876", callback: { [weak self] peripheral, error in
            self?.peripheral = peripheral
            print("==========\(String(describing: peripheral?.name))=====\(String(describing: peripheral?.identifierString))")
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    var bleManager:TFYSwIFTEasyBlueToothManager? {
        didSet {
            let mange = bleManager
            if mange != nil {
                self.data = mange!
            }
        }
    }
}

extension TFYSwiftExampleScanNameController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let withIdentifier:String = "\(String(format: "%ld", indexPath.row))"
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: withIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: withIdentifier)
        }
        
        cell?.textLabel?.text = dataArr[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data:Data = "22HY63475E15".blueheadecimal()!
        if indexPath.row == 0 {
            self.writeDataWithPeripheral(data: data)
        } else if indexPath.row == 1 {
            self.writeDataWithPeripheral(data: data)
        } else if indexPath.row == 2 {
            self.writeDataWithPeripheral(data: data)
        } else if indexPath.row == 3 {
            self.writeDataWithPeripheral(data: data)
        } else if indexPath.row == 4 {
            self.writeDataWithPeripheral(data: data)
        } else if indexPath.row == 5 {
            self.writeDataWithPeripheral(data: data)
        } else if indexPath.row == 6 {
            TFYProgressSwiftHUD.show("提示...")
            TFYSwiftAsynce.async {
                self.data?.readValueWithPeripheral(peripheral: self.peripheral!, serviceUUID: UUID_SERVICE, readUUID: UUID_READ, callback: { value, error in
                    TFYSwiftAsynce.async {
                    } _: {
                        if error != nil {
                            TFYProgressSwiftHUD.showError(error?.localizedDescription)
                        } else {
                            let string:String = (value as! Data).bluehexString()
                            TFYProgressSwiftHUD.showSucceed(string)
                        }
                    }
                })
            }
        } else if indexPath.row == 7 {
            TFYProgressSwiftHUD.show("提示...")
            TFYSwiftAsynce.async {
                self.data?.notifyDataWithPeripheral(peripheral: self.peripheral!, serviceUUID: UUID_SERVICE, notifyUUID: UUID_NOTIFICATION, notifyValue: true, callback: { value, error in
                    TFYSwiftAsynce.async {
                    } _: {
                        if error != nil {
                            TFYProgressSwiftHUD.showError(error?.localizedDescription)
                        } else {
                            let string:String = (value as! Data).bluehexString()
                            TFYProgressSwiftHUD.showSucceed(string)
                        }
                    }
                })
            }
        } else if indexPath.row == 8 {
            TFYProgressSwiftHUD.show("提示...")
            TFYSwiftAsynce.async {
                self.data?.notifyDataWithPeripheral(peripheral: self.peripheral!, serviceUUID: UUID_SERVICE, notifyUUID: UUID_NOTIFICATION, notifyValue: false, callback: { value, error in
                    TFYSwiftAsynce.async {
                    } _: {
                        if error != nil {
                            TFYProgressSwiftHUD.showError(error?.localizedDescription)
                        } else {
                            let string:String = (value as! Data).bluehexString()
                            TFYProgressSwiftHUD.showSucceed(string)
                        }
                    }
                })
            }
        }
    }
    
    func writeDataWithPeripheral(data:Data) {
        TFYSwiftAsynce.async {
            self.data?.writeDataWithPeripheral(peripheral: self.peripheral!, serviceUUID: UUID_SERVICE, writeUUID: UUID_WRITE, data: data, callback: { value, error in
                TFYSwiftAsynce.async {
                } _: {
                    if error != nil {
                        TFYProgressSwiftHUD.showError(error?.localizedDescription)
                    } else {
                        let string:String = (value as! Data).bluehexString()
                        TFYProgressSwiftHUD.showSucceed(string)
                    }
                }
            })
        }
    }
}

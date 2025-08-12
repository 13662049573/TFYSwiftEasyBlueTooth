//
//  TFYSwiftDetailOperationController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftDetailOperationController: UIViewController {

    lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect.zero, style: .grouped)
        tab.showsHorizontalScrollIndicator = false
        tab.contentInsetAdjustmentBehavior = .never
        tab.rowHeight = 50
        tab.estimatedSectionFooterHeight = 0.01
        tab.estimatedSectionHeaderHeight = 0.01
        tab.backgroundColor = .white
        tab.delegate = self
        tab.dataSource = self
        return tab
    }()
    
    private var dataArray:[String] = [String]()
    private var currentField:UITextField = UITextField()
    var kvoToken: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(tableView)
        
        if data != nil {
            kvoToken = data?.observe(\.notifyDataArray, options: .new, changeHandler: { charac, change in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    var data:TFYSwiftEasyCharacteristic? {
        didSet {
            let charcter = data
            if charcter != nil {
                self.dataArray = (charcter?.propertiesString.components(separatedBy: " "))!
                self.tableView.reloadData()
            }
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }

}

extension TFYSwiftDetailOperationController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < dataArray.count {
            let tempString:String = dataArray[section]
            if tempString.contains("Write,WithoutResponse") {
                return (self.data?.writeDataArray.count)! + 1
            } else if tempString.contains("Read") {
                return (self.data?.readDataArray.count)! + 1
            } else if tempString.contains("Notify,indicate") {
                return (self.data?.notifyDataArray.count)! + 1
            } else {
                return 0
            }
        } else if section == dataArray.count {
            return (self.data?.descriptorArray.count)!
        } else {
            return dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let withIdentifier:String = "\(String(format: "%ld", indexPath.row))"
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: withIdentifier)
        cell?.accessoryType = indexPath.section != 0 ? .disclosureIndicator : .none
        if cell == nil {
            cell = TFYSwiftDetailOperationCell(style: .subtitle, reuseIdentifier: withIdentifier)
        }
        if indexPath.section < dataArray.count {
            let tempString:String = dataArray[indexPath.section]
            if indexPath.row == 0 {
                (cell as! TFYSwiftDetailOperationCell).title = "\(tempString) 新的价值"
                if tempString.contains("Notify") {
                    (cell as! TFYSwiftDetailOperationCell).title = "\((self.data?.isNotifying)! ? "停止通知" : "点击开始通知")"
                }
            } else {
                if tempString.contains("Write,WithoutResponse") {
                    (cell as! TFYSwiftDetailOperationCell).title = (self.data?.writeDataArray[indexPath.row-1].bluehexString())!
                } else if tempString.contains("Read") {
                    (cell as! TFYSwiftDetailOperationCell).title = (self.data?.readDataArray[indexPath.row-1].bluehexString())!
                } else if tempString.contains("Notify,indicate") {
                    (cell as! TFYSwiftDetailOperationCell).title = (self.data?.notifyDataArray[indexPath.row-1].bluehexString())!
                }
            }
        } else if indexPath.section == dataArray.count {
            let tempD:TFYSwiftEasyDescriptor = (self.data?.descriptorArray[indexPath.row])!
            (cell as! TFYSwiftDetailOperationCell).title = "\(tempD.UUID?.uuidString ?? "")"
        } else {
            (cell as! TFYSwiftDetailOperationCell).title = dataArray[indexPath.row]
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let herherView:TFYSwiftDetailHeaderFooterView = TFYSwiftDetailHeaderFooterView()
        if section < dataArray.count {
            herherView.serviceName = dataArray[section]
        } else if section == dataArray.count {
            herherView.serviceName = "描述"
        } else {
            herherView.serviceName = "性能"
        }
        return herherView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section < dataArray.count && (indexPath.row == 0) {
            let tempString:String = dataArray[indexPath.section]
            if tempString.contains("Write,WithoutResponse") {
                let alert:UIAlertController = UIAlertController(title: "提示", message: "输入文字", preferredStyle: .alert)
                let action:UIAlertAction = UIAlertAction(title: "取消", style: .cancel)
                let action2:UIAlertAction = UIAlertAction(title: "确定", style: .default) { action in
                    if !(self.currentField.text?.isEmpty ?? false) {
                        let data:Data? = self.currentField.text?.blueheadecimal()
                        self.data?.writeValueWithData(data: data, callback: { characteristic, data, error in
                            if data != nil {
                                let string:String = data!.bluehexString()
                                print("Write/WithoutResponse====:\(string)")
                            }
                        })
                        tableView.reloadData()
                    }
                }
                alert.addTextField { text in
                    text.keyboardType = .namePhonePad
                    self.currentField = text
                }
                alert.addAction(action)
                alert.addAction(action2)
                self.present(alert, animated: true)
            } else if tempString.contains("Read") {
                self.data?.readValueWithCallback(callback: { characteristic, data, error in
                    if data != nil {
                        let string:String = data!.bluehexString()
                        print("Read===:\(string)")
                    }
                    tableView.reloadData()
                })
            } else if tempString.contains("Notify,indicate"){
                self.data?.notifyWithValue(value: (self.data?.isNotifying)!, callback: { characteristic, data, error in
                    if data != nil {
                        let string:String = data!.bluehexString()
                        print("Notify/Indicate==:\(string)")
                    }
                    tableView.reloadData()
                })
            }
        }
    }
}

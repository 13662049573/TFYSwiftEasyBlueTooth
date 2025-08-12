//
//  TFYSwiftDetailViewController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit
import TFYProgressSwiftHUD

class TFYSwiftDetailViewController: UIViewController {

    private let width_w:CGFloat = UIScreen.main.bounds.width
    
    private var exitBreakUp:Bool = true
    
    private lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect.zero, style: .plain)
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
    
    lazy var herderView: TFYSwiftDetailHeaderView = {
        let herder = TFYSwiftDetailHeaderView(frame: CGRect(x: 0, y: 0, width: width_w, height: 80))
        return herder
    }()
    
    private var advertisementArray:[String] = [String]()
    private var peripheral:TFYSwiftEasyPeripheral?
    private var isShowfirstSection:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "蓝牙详情"
        herderView.peripheral = self.peripheral
        tableView.tableHeaderView = herderView
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "退出断开连接", style: .plain, target: self, action: #selector(barbuttonClick))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if exitBreakUp {
            peripheral?.disconnectDevice()
        }
    }

    var data:TFYSwiftEasyPeripheral? {
        didSet {
            let peripheral = data
            if let peripheral = peripheral {
                peripheral.advertisementData.keys.forEach { idstring in
                    advertisementArray.append(idstring)
                }
                self.peripheral = peripheral
                blueLayoueData()
            }
        }
    }
    
    func blueLayoueData() {
        TFYProgressSwiftHUD.show()
        self.peripheral?.discoverAllDeviceServiceWithCallback(callback: { [weak self] peripheral, serviceArray, error in
            guard let self = self else { return }
            
            serviceArray.forEach { tempS in
                tempS.discoverCharacteristicWithCharacteristicUUIDs { characteristics, error in
                    characteristics.forEach { tempC in
                        tempC.discoverDescriptorWithCallback { descriptorArray, error in
                            if descriptorArray.count > 0 {
                                descriptorArray.forEach { tempD in
                                    print("获取数据===UUID：\(String(describing: tempD.UUID))----value：\(String(describing: tempD.value))")
                                }
                                descriptorArray.forEach { tempE in
                                    tempE.readValueWithCallback { descriptor, error in
                                        print("获取数据===value：\(String(describing: descriptor.value))----error：\(String(describing: error))")
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    TFYProgressSwiftHUD.dismiss()
                                }
                            }
                        }
                    }
                }
            }
        })
        self.tableView.reloadData()
    }
    
    @objc func barbuttonClick(item:UIBarButtonItem) {
        if ((item.title?.contains("退出断开连接")) != nil) {
            exitBreakUp = false
            item.title = "退出不断开连接"
        } else {
            exitBreakUp = true
            item.title = "退出断开连接"
        }
    }
    
    deinit {
        if exitBreakUp {
            peripheral?.disconnectDevice()
        }
    }
}

extension TFYSwiftDetailViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ((self.peripheral?.serviceArray.count ?? 0) + 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section != 0) {
            guard let tempService = self.peripheral?.serviceArray[section-1] else { return 0 }
            return tempService.characteristicArray.count
        }
        if (isShowfirstSection != 0) {
            return (self.peripheral?.advertisementData.count ?? 0)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let herherView:TFYSwiftDetailHeaderFooterView = TFYSwiftDetailHeaderFooterView()
        var serviceName:String = "广告数据"
        if section != 0 {
            guard let tempS = self.peripheral?.serviceArray[section-1] else { return herherView }
            serviceName = tempS.name
        }
        herherView.serviceName = serviceName
        herherView.sectionState = section == 0 ? isShowfirstSection:-1
        herherView.callback = { [weak self] isShow in
            self?.isShowfirstSection = isShow
            self?.tableView.reloadSections([0], with: .fade)
        }
        return herherView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let withIdentifier:String = "\(String(format: "%ld", indexPath.row))"
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: withIdentifier)
        cell?.accessoryType = indexPath.section != 0 ? .disclosureIndicator : .none
        if cell == nil {
            cell = TFYSwiftDetailOneTableViewCell(style: .subtitle, reuseIdentifier: withIdentifier)
        }
        if indexPath.section != 0 {
            guard let tempS = self.peripheral?.serviceArray[indexPath.section-1],
                  indexPath.row < tempS.characteristicArray.count else { return cell! }
            let tempC:TFYSwiftEasyCharacteristic = tempS.characteristicArray[indexPath.row]
            (cell as! TFYSwiftDetailOneTableViewCell).data = tempC
        } else {
            guard indexPath.row < self.advertisementArray.count else { return cell! }
            (cell as! TFYSwiftDetailOneTableViewCell).titleString = self.advertisementArray[indexPath.row]
            let title:Any = self.advertisementArray[indexPath.row]
            var allString:String = ""
            if title is [Any] {
                let tempArray:[Any] = (title as! [Any])
                tempArray.forEach { tempS in
                    allString = (allString as NSString).appending(" \(tempS)")
                }
            } else {
                allString = title as! String
            }
            (cell as! TFYSwiftDetailOneTableViewCell).subTitleString = self.peripheral?.advertisementData[allString]
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section != 0 {
            guard let tempS = self.peripheral?.serviceArray[indexPath.section-1],
                  indexPath.row < tempS.characteristicArray.count else { return }
            let tempC:TFYSwiftEasyCharacteristic = tempS.characteristicArray[indexPath.row]
            let vc:TFYSwiftDetailOperationController = TFYSwiftDetailOperationController()
            vc.data = tempC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

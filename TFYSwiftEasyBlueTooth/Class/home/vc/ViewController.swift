//
//  ViewController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/9.
//

import UIKit
import TFYProgressSwiftHUD

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.centerManager.startScanDevice()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.centerManager.stopScanDevice()
    }
    
    private var dataArray:[TFYSwiftEasyPeripheral] = [TFYSwiftEasyPeripheral]()
    
    private lazy var centerManager: TFYSwiftEasyCenterManager = {
        let manage = TFYSwiftEasyCenterManager(queue: DispatchQueue.main)
        return manage
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "蓝牙数据"
        
        view.addSubview(tableView)
        
        blueLayouData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // 搜索蓝牙数据
    func blueLayouData() {
        centerManager.scanDeviceWithTimeInterval(timeInterval: 20) { [weak self] peripheral, searchType in
            guard let self = self else { return }
            
            if let peripheral = peripheral {
                if searchType == .searchFlagTypeAdded {
                    if !self.dataArray.contains(peripheral) {
                        self.dataArray.append(peripheral)
                    }
                } else if searchType == .searchFlagTypeDisconnect || searchType == .searchFlagTypeDelete {
                    if !self.dataArray.contains(peripheral) {
                        self.dataArray.append(peripheral)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    deinit {
        centerManager.stopScanDevice()
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let withIdentifier:String = "\(String(format: "%ld", indexPath.row))"
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: withIdentifier)
        if cell == nil {
            cell = TFYViewTableViewCell(style: .subtitle, reuseIdentifier: withIdentifier)
        }
        
        let data:TFYSwiftEasyPeripheral = self.dataArray[indexPath.row]
        
        (cell as! TFYViewTableViewCell).data = data
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.centerManager.stopScanDevice()
        let data:TFYSwiftEasyPeripheral = self.dataArray[indexPath.row]
        
        if data.state == .connected {
            let vc:TFYSwiftDetailViewController = TFYSwiftDetailViewController()
            vc.data = data
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            TFYProgressSwiftHUD.show()
            data.connectDeviceWithTimeOut { [weak self] perpheral, error, type in
                DispatchQueue.main.async {
                    TFYProgressSwiftHUD.dismiss()
                    
                    switch type {
                    case .deviceConnectTypeDisConnect:
                        let aler:UIAlertController = UIAlertController(title: "设备失去连接", message: error?.localizedDescription ?? "连接失败", preferredStyle: .alert)
                        let alerAction:UIAlertAction = UIAlertAction(title: "重新连接", style: .default) { action in
                            data.reconnectDevice()
                        }
                        let alerAction2:UIAlertAction = UIAlertAction(title: "取消", style: .cancel) { action in
                            aler.dismiss(animated: true)
                        }
                        aler.addAction(alerAction)
                        aler.addAction(alerAction2)
                        self?.present(aler, animated: true)
                        
                    case .deviceConnectTypeSuccess:
                        let vc:TFYSwiftDetailViewController = TFYSwiftDetailViewController()
                        vc.data = data
                        vc.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    case .deviceConnectTypeFaild, .deviceConnectTypeFaildTimeout:
                        let aler:UIAlertController = UIAlertController(title: "连接失败", message: error?.localizedDescription ?? "连接失败", preferredStyle: .alert)
                        let alerAction:UIAlertAction = UIAlertAction(title: "确定", style: .default)
                        aler.addAction(alerAction)
                        self?.present(aler, animated: true)
                    }
                }
            }
        }
    }
}

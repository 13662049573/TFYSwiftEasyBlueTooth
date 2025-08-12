//
//  TFYSwiftEasyCenterManager.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import UIKit
import CoreBluetooth

public enum searchFlagType:Int {
    case searchFlagTypeDefaut = 0
    case searchFlagTypeFinish = 1 //扫描时间到
    case searchFlagTypeDisconnect = 2 //设备断开连接 删除设别
    case searchFlagTypeAdded = 3 //扫描到新设备
    case searchFlagTypeChanged = 4 //已经扫描到设备，设备的状态改变
    case searchFlagTypeDelete = 5 //设备超过时间未被发现
}

public class TFYSwiftEasyCenterManager: NSObject {
    
    private var centerState:CBManagerState? //当前系统蓝牙状态
    private var canTimeInterval:Int? = LONG_MAX
    private var scanServicesArray:[CBUUID]? = [CBUUID]()
    private var scanOptionsDictionary:[String:Any]? = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
    private var blueToothSearchDeviceCallback:blueToothSearchDeviceCallback?
    private var peripheral:TFYSwiftEasyPeripheral?
    
    // 添加线程安全保护
    private let deviceQueue = DispatchQueue(label: "com.tfy.bluetooth.device", attributes: .concurrent)
    
    /// 搜索到设备的回到，只要系统搜索到设备，都会回调这个block
    typealias blueToothSearchDeviceCallback = (_ peripheral:TFYSwiftEasyPeripheral?,_ searchType:searchFlagType) -> Void
    /// 系统蓝牙状态改变
    typealias blueToothStateChangedCallback = (_ manager:TFYSwiftEasyCenterManager,_ state:CBManagerState) -> Void
    
    /// 中心管理者
    var manager:CBCentralManager = CBCentralManager()
    
    /// 当前的蓝牙状态
    var stateChangeCallback:blueToothStateChangedCallback?
    
    /// 是否正在扫描周围设备
    var isScanning:Bool = false
    
    /// 已经连接上的设备 key:设备的identifier value:连接上的设备
    var connectedDeviceDict:[String:Any] = [String:Any]() {
        didSet {
            // 设备连接状态变化通知
            deviceQueue.async(flags: .barrier) { [weak self] in
                self?.notifyDeviceConnectionStateChanged()
            }
        }
    }
    
    /// 已经发现的设备 key:设备的identifier value:连接上的设备 (已经去掉了重复的设备)
    var foundDeviceDict:[String:Any] = [String:Any]() {
        didSet {
            // 设备发现状态变化通知
            deviceQueue.async(flags: .barrier) { [weak self] in
                self?.notifyDeviceDiscoveryStateChanged()
            }
        }
    }
    
    /// queue 为manager运行的线程，传空就是在主线程上
    init(queue:DispatchQueue?,options:[String:Any]? = [String:Any]()) {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: queue, options: options)
        self.canTimeInterval = LONG_MAX
    }
    
    /// 扫描周围设备
    func startScanDevice() {
        self.scanDeviceWithTimeCallback(callBack: self.blueToothSearchDeviceCallback)
    }
    
    func scanDeviceWithTimeCallback(callBack:blueToothSearchDeviceCallback?) {
        self.scanDeviceWithTimeInterval(callBack: callBack)
    }
    
    func scanDeviceWithTimeInterval(timeInterval:Int,callBack:blueToothSearchDeviceCallback?) {
        self.scanDeviceWithTimeInterval(timeInterval: timeInterval, service: self.scanServicesArray, options: self.scanOptionsDictionary, callBack: callBack)
    }
    
    func scanDeviceWithTimeInterval(timeInterval:Int? = LONG_MAX,service:[CBUUID]? = nil,options:[String:Any]? = nil,callBack:blueToothSearchDeviceCallback?) {
        self.canTimeInterval = timeInterval
        self.scanOptionsDictionary = options
        self.scanServicesArray = service
        if callBack != nil {
            self.blueToothSearchDeviceCallback = callBack
        }
        self.stopScanDevice()
        self.isScanning = true
        
        let connectedArray:[TFYSwiftEasyPeripheral]? = self.retrieveConnectedPeripheralsWithServices(serviceUUIDS: service)
        if connectedArray != nil {
            connectedArray?.forEach({ easyP in
                self.peripheral = easyP
                var isExited:Bool = false
                for (_,tempIdentify) in self.foundDeviceDict.keys.enumerated() {
                    if tempIdentify.contains(easyP.identifierString!) {
                        isExited = true
                        break
                    }
                }
                if !isExited {
                    self.foundDeviceDict.updateValue(easyP, forKey: easyP.identifierString!)
                }
                if self.blueToothSearchDeviceCallback != nil {
                    self.blueToothSearchDeviceCallback!(easyP,isExited ? .searchFlagTypeChanged : .searchFlagTypeAdded)
                }
            })
        }
        print("\(String(format: "开始扫描设备 - 倒计时时长==%ld====秒", timeInterval!))")
        self.manager.scanForPeripherals(withServices: service, options: options)
        
        //指定时间通知外部，扫描完成
        TFYSwiftAsynce.asyncDelay(Double(timeInterval!)) { [weak self] in
            guard let self = self else { return }
            self.isScanning = false
            if self.manager.isScanning && self.blueToothSearchDeviceCallback != nil {
                self.stopScanDevice()
                self.blueToothSearchDeviceCallback!(self.peripheral,.searchFlagTypeFinish)
                print("描述结束----\(timeInterval!)")
            }
            
            self.foundDeviceDict.values.forEach({ tempP in
                if let peripheral = tempP as? TFYSwiftEasyPeripheral {
                    NSObject.cancelPreviousPerformRequests(withTarget: peripheral, selector: #selector(peripheral.devicenotFoundTimeout), object: nil)
                }
            })
        }
    }
    
    /// 停止扫描，当还没有达到扫描时间，但是已经找到了想要连接的设别，可以调用它来停止扫描
    func stopScanDevice() {
        if self.isScanning {
            self.isScanning = false
        }
        self.manager.stopScan()
    }
    
    /// 清空所有发现的设备
    func removeAllScanFoundDevice() {
        self.foundDeviceDict.removeAll()
    }
    
    /// 断开所有连接的设备
    func disConnectAllDevice() {
        self.connectedDeviceDict.values.forEach { tempPeripheral in
            if let temp = tempPeripheral as? TFYSwiftEasyPeripheral {
                temp.disconnectDevice()
            }
        }
    }
    
    /// 一段时间没有扫描到设备，通知外部处理
    func foundDeviceTimeout(perpheral:TFYSwiftEasyPeripheral) {
        var allValues:[Any] = [Any]()
        if self.connectedDeviceDict.count > 0 {
            self.connectedDeviceDict.values.forEach { data in
                allValues.append(data)
            }
            for (_,obj) in allValues.enumerated() {
                if (obj as AnyObject).isEqual(perpheral) {
                    return
                }
            }
        }
        
        if self.foundDeviceDict.count > 0 {
            var isExitDevice:Bool = false
            var tempAllValues:[Any] = [Any]()
            self.foundDeviceDict.values.forEach { data in
                tempAllValues.append(data)
            }
            for (_,obj) in tempAllValues.enumerated() {
                if (obj as AnyObject).isEqual(perpheral) {
                    isExitDevice = true
                    break
                }
            }
            if isExitDevice {
                self.foundDeviceDict.removeValue(forKey: perpheral.identifierString!)
                if self.blueToothSearchDeviceCallback != nil {
                    self.blueToothSearchDeviceCallback!(perpheral,.searchFlagTypeDelete)
                }
            }
        }
    }
    
    /// 寻找当前连接的设备
    func searchDeviceWithPeripheral(peripheral:CBPeripheral) -> TFYSwiftEasyPeripheral? {
        var result:TFYSwiftEasyPeripheral?
        self.connectedDeviceDict.values.forEach { tempPeripheral in
            if let temp = tempPeripheral as? TFYSwiftEasyPeripheral {
                if temp.peripheral?.isEqual(peripheral) == true {
                    result = temp
                }
            }
        }
        return result
    }
    
    /// 回去已经连接上的设备
    func retrievePeripheralsWithIdentifiers(identifiers:[UUID]) -> [TFYSwiftEasyPeripheral]? {
        
        let resultArray:[CBPeripheral]? = self.manager.retrievePeripherals(withIdentifiers: identifiers)
        var tempArray:[TFYSwiftEasyPeripheral] = []
        if let resultArray = resultArray {
            resultArray.forEach({ tempP in
                let tempPer:TFYSwiftEasyPeripheral = TFYSwiftEasyPeripheral(peripheral: tempP, manager: self)
                tempArray.append(tempPer)
            })
        }
        return tempArray
    }
    
    func retrieveConnectedPeripheralsWithServices(serviceUUIDS:[CBUUID]?) -> [TFYSwiftEasyPeripheral]? {
        if serviceUUIDS != nil {
            let resultArray:[CBPeripheral] = (self.manager.retrieveConnectedPeripherals(withServices: serviceUUIDS!))
            var tempArray:[TFYSwiftEasyPeripheral] = []
            if resultArray.count > 0 {
                resultArray.forEach({ tempP in
                    let tempPer:TFYSwiftEasyPeripheral = TFYSwiftEasyPeripheral(peripheral:tempP, manager: self)
                    tempArray.append(tempPer)
                })
            }
            return tempArray
        }
        return nil
    }
    
    /// 通知设备连接状态变化
    private func notifyDeviceConnectionStateChanged() {
        NotificationCenter.default.post(name: NSNotification.Name("TFYBluetoothDeviceConnectionStateChanged"), object: self.connectedDeviceDict)
    }
    
    /// 通知设备发现状态变化
    private func notifyDeviceDiscoveryStateChanged() {
        NotificationCenter.default.post(name: NSNotification.Name("TFYBluetoothDeviceDiscoveryStateChanged"), object: self.foundDeviceDict)
    }
    
    deinit {
        stopScanDevice()
        disConnectAllDevice()
        removeAllScanFoundDevice()
    }
}


extension TFYSwiftEasyCenterManager:CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if self.centerState != nil {
            if self.centerState != central.state {
                if self.stateChangeCallback != nil {
                    self.stateChangeCallback!(self,central.state)
                }
            }
        }
        self.centerState = central.state
        if self.centerState == .unsupported {
            let alert:UIAlertController = UIAlertController(title: "提示", message: "此设备不支持BLE4.0,请更换设备", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            UIWindow.bluekeyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } else if central.state == .poweredOn {
            self.manager = central
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    /// 搜索到新的外设
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心
    ///   - peripheral: 外设
    ///   - advertisementData: 外设广播内容
    ///   - RSSI: 信号
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("发现一个设备==name:\(String(describing: peripheral.name))---identifier==:\(peripheral.identifier)")
        
        //去掉重复搜索到的设备
        var existedIndex:Int = -1
        self.foundDeviceDict.keys.forEach { tempIndefy in
            if tempIndefy.contains(peripheral.identifier.uuidString) {
                if let tempP = self.foundDeviceDict[tempIndefy] as? TFYSwiftEasyPeripheral {
                    tempP.deviceScanCount += 1
                    existedIndex = tempP.deviceScanCount
                }
            }
        }
        
        if existedIndex == -1 {
            let easyP:TFYSwiftEasyPeripheral = TFYSwiftEasyPeripheral(peripheral: peripheral, manager: self)
            easyP.RSSI = RSSI
            easyP.advertisementData = advertisementData
            self.foundDeviceDict.updateValue(easyP, forKey: easyP.identifierString!)
            if self.blueToothSearchDeviceCallback != nil {
                self.blueToothSearchDeviceCallback!(easyP,.searchFlagTypeAdded)
            }
        } else if existedIndex%10 == 0 {
            if let tempP = self.foundDeviceDict[peripheral.identifier.uuidString] as? TFYSwiftEasyPeripheral {
                tempP.RSSI = RSSI
                tempP.deviceScanCount = 0
                tempP.advertisementData = advertisementData
                if self.blueToothSearchDeviceCallback != nil {
                    self.blueToothSearchDeviceCallback!(tempP,.searchFlagTypeChanged)
                }
            }
        }
    }
    
    /// 连接外设成功
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心
    ///   - peripheral: 外设
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("蓝牙连接上一个设备：\(peripheral)--uuidString:\(peripheral.identifier.uuidString)")
        
        var existedP:TFYSwiftEasyPeripheral? = nil
        self.connectedDeviceDict.keys.forEach { tempIden in
            if tempIden.contains(peripheral.identifier.uuidString) {
                existedP = (self.connectedDeviceDict[tempIden] as! TFYSwiftEasyPeripheral)
            }
        }
        
        if existedP == nil {
            for (_,obj) in self.foundDeviceDict.keys.enumerated() {
                if obj.contains(peripheral.identifier.uuidString) {
                    existedP = (self.foundDeviceDict[obj] as! TFYSwiftEasyPeripheral)
                    break
                }
            }
            
            if existedP != nil {
                self.connectedDeviceDict.updateValue(existedP as Any, forKey: peripheral.identifier.uuidString)
            } else {
                existedP = TFYSwiftEasyPeripheral(peripheral: peripheral, manager: self)
                self.connectedDeviceDict.updateValue(existedP as Any, forKey: peripheral.identifier.uuidString)
                self.foundDeviceDict.updateValue(existedP as Any, forKey: peripheral.identifier.uuidString)
            }
        }
        let error:Error? = nil
        existedP?.dealDeviceConnectWithError(error: error, type: .deviceConnectTypeSuccess)
    }
    
    /// 连接外设失败
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心
    ///   - peripheral: 外设
    ///   - error: 错误
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("蓝牙连接一个设备失败：uuid\(peripheral.identifier.uuidString)==errror:\(String(describing: error))")
        var existedP:TFYSwiftEasyPeripheral?
        self.connectedDeviceDict.keys.forEach { tempP in
            if tempP.contains(peripheral.identifier.uuidString) {
                existedP = (self.connectedDeviceDict[tempP] as! TFYSwiftEasyPeripheral)
            }
        }
        
        if existedP != nil {
            self.connectedDeviceDict.removeValue(forKey: (existedP?.identifierString!)!)
        } else {
            self.foundDeviceDict.keys.forEach { tempIden in
                if tempIden.contains(peripheral.identifier.uuidString) {
                    existedP = (self.foundDeviceDict[tempIden] as! TFYSwiftEasyPeripheral)
                }
            }
            print("注意：您应该处理此错误")
        }
        
        if self.blueToothSearchDeviceCallback != nil && existedP != nil {
            self.blueToothSearchDeviceCallback!(existedP!,.searchFlagTypeDisconnect)
        }
        
        if existedP != nil {
            existedP?.dealDeviceConnectWithError(error: error, type: .deviceConnectTypeFaild)
        }
    }
    
    /// 外设断开连接
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心
    ///   - peripheral: 外设
    ///   - error: 错误
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙一个设备失去连接：uuid:\(peripheral.identifier.uuidString)===error:\(String(describing: error))")
        var existedP:TFYSwiftEasyPeripheral?
        self.connectedDeviceDict.keys.forEach { tempIden in
            if tempIden.contains(peripheral.identifier.uuidString) {
                existedP = (self.connectedDeviceDict[tempIden] as! TFYSwiftEasyPeripheral)
            }
        }
        
        if (existedP != nil) {
            existedP?.serviceArray.forEach({ tempS in
                tempS.characteristicArray.removeAll()
                tempS.isOn = false
                tempS.isEnabled = false
            })
            existedP?.serviceArray.removeAll()
            self.connectedDeviceDict.removeValue(forKey: (existedP?.identifierString!)!)
            self.foundDeviceDict.removeValue(forKey: (existedP?.identifierString!)!)
        } else {
            print("注意：您应该处理此错误")
        }
        
        if self.blueToothSearchDeviceCallback != nil && existedP != nil {
            self.blueToothSearchDeviceCallback!(existedP!,.searchFlagTypeDisconnect)
        }
        if error != nil && existedP != nil {
            existedP?.dealDeviceConnectWithError(error: error!, type: .deviceConnectTypeDisConnect)
        }
        existedP = nil
    }
    
    
}

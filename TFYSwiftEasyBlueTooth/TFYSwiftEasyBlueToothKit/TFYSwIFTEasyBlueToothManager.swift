//
//  TFYSwIFTEasyBlueToothManager.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/14.
//

import UIKit
import CoreBluetooth

/// 一个蓝牙设备读写数据，所经历的全部的生命周期
public enum bluetoothState:Int {
    ///蓝牙准备就绪
    case bluetoothStateSystemReadly = 1
    ///设备已被发现
    case bluetoothStateDeviceFounded = 2
    ///设备连接成功
    case bluetoothStateDeviceConnected = 3
    ///获取服务
    case bluetoothStateServiceFounded = 4
    /// 获取特征
    case bluetoothStateCharacterFounded = 5
    /// 监听通知成功
    case bluetoothStateNotifySuccess = 6
    /// 读取数据成功
    case bluetoothStateReadSuccess = 7
    /// 写数据成功
    case bluetoothStateWriteDataSuccess = 8
    /// 断开设备
    case bluetoothStateDestory = 9
}

/// 错误的报错类型
public enum bluetoothErrorState:Int {
    ///系统蓝牙没有打开。但是在扫描时间内，会等待蓝牙打开后继续扫描。所以千万要注意：需要等待bluetoothErrorStateNoReadly时才停止扫描，里面的所有事件才会停止.
    case bluetoothErrorStateNoReadlyTring = 0
    ///系统蓝牙没有打开。此时不会再自动扫描，只能重新扫描
    case bluetoothErrorStateNoReadly = 1
    ///没有找到设备
    case bluetoothErrorStateNoDevice = 2
    ///连接失败
    case bluetoothErrorStateConnectError = 3
    /// 设别没有连接
    case bluetoothErrorStateNoConnect = 4
    /// 设备失去连接
    case bluetoothErrorStateDisconnect = 5
    /// 设备失去连接 ,但是设置了自从重连，正在重连
    case bluetoothErrorStateDisconnectTring = 6
    /// 没有找到相应的服务
    case bluetoothErrorStateNoService = 7
    /// 没有对应的特征
    case bluetoothErrorStateNoCharcter = 8
    ///写数据失败
    case bluetoothErrorStateWriteError = 9
    /// 读书节失败
    case bluetoothErrorStateReadError = 10
    /// 监听通知失败
    case bluetoothErrorStateNotifyError = 11
    /// 没有对应的特征
    case bluetoothErrorStateNoDescriptor = 12
    /// identifier不符合规则
    case bluetoothErrorStateIdentifierError = 13
}

public class TFYSwIFTEasyBlueToothManager: NSObject {
    
    private lazy var centerManager: TFYSwiftEasyCenterManager = {
        let manage:TFYSwiftEasyCenterManager = TFYSwiftEasyCenterManager(queue: self.managerOptions?.managerQueue, options: self.managerOptions?.managerDictionary)
        manage.stateChangeCallback = { [weak self] manager,state in
            if state == .poweredOn {
                self?.bluetoothState = .bluetoothStateSystemReadly
                if self?.bluetoothStateChanged != nil {
                    let peripheral:TFYSwiftEasyPeripheral? = nil
                    self!.bluetoothStateChanged!(peripheral!,.bluetoothStateSystemReadly)
                }
                manage.startScanDevice()
            }
        }
        return manage
    }()
    
    var managerOptions: TFYSwiftEasyManagerOptions? = TFYSwiftEasyManagerOptions(queue: nil)
    
    /// 连接设备的时候蓝牙状态发生改变
    typealias blueToothStateChanged = (_ peripheral:TFYSwiftEasyPeripheral?,_ state:bluetoothState) -> Void
    
    /// 模糊搜索设备规则
    /// 用户可以自定义，依据peripheral里面的名称，广播数据，RSSI来赛选需要的连接的设备
    typealias blueToothScanRule = (_ peripheral:TFYSwiftEasyPeripheral) -> Bool
    
    /// 第一种：扫描到符合条件的单个设别就立马回调。
    /// 第二种：在规定的时间里扫描出所有和服条件的设备，它会等到所规定的时间完成才会回调。
    typealias blueToothScanCallback = (_ peripheral:TFYSwiftEasyPeripheral?,_ error:Error?) -> Void
    typealias blueToothScanAsyncCallback = (_ peripheral:TFYSwiftEasyPeripheral,_ type:searchFlagType,_ error:Error?) -> Void
    typealias blueToothScanAllCallback = (_ deviceArray:[TFYSwiftEasyPeripheral],_ error:Error?) -> Void
    
    /// 连接设备的回调
    /// 说明：error为nil的时候说明连接成功。如果error里面有值，请做相应的处理
    typealias blueToothConnectCallback = (_ peripheral:TFYSwiftEasyPeripheral?,_ error:Error?) -> Void
    
    /// 读/写/监听特征 操作回调
    typealias blueToothOperationCallback = (_ value:Any?,_ error:Error?) -> Void
    
    /// 寻找特征的回调
    typealias blueToothFindCharacteristic = (_ character:TFYSwiftEasyCharacteristic?,_ error:Error?) -> Void
    
    /// 方法一：外部可以KVO监听bluetoothState值的改变。
    /// 方法二：bluetoothStateChanged 实现这个block回到
    var bluetoothState:bluetoothState?
    var bluetoothStateChanged:blueToothStateChanged?
    
    /// 单例
    static var shareInstance:TFYSwIFTEasyBlueToothManager {
        struct Static {
            static let inst:TFYSwIFTEasyBlueToothManager = TFYSwIFTEasyBlueToothManager()
        }
        return Static.inst
    }
    
    /// 扫描单个设备 ---> 发现第一个设备符合name/rule的规则就会回调callback，停止扫描。
    func scanDeviceWithName(name:String,callback:blueToothScanCallback?) {
        self.scanDeviceWithCondition(condition: name, callback: callback)
    }
    func scanDeviceWithRule(rule:blueToothScanRule?,callback:blueToothScanCallback?) {
        self.scanDeviceWithCondition(condition: rule, callback: callback)
    }
    
    /// 扫描符合规则的全部设备 ---> 发现一个回调一个。当到规定的时间停止扫描。
    func scanAllDeviceAsyncWithRule(rule:blueToothScanRule?,callback:blueToothScanAsyncCallback?) {
        if self.managerOptions?.scanTimeOut == NSIntegerMax {
            self.managerOptions?.scanTimeOut = 20
        }
        self.centerManager.scanDeviceWithTimeInterval(timeInterval: self.managerOptions?.scanTimeOut, service: self.managerOptions?.scanServiceArray, options: self.managerOptions?.scanOptions) { [weak self] peripheral, searchType in
            if searchType == .searchFlagTypeFinish {
                self?.centerManager.stopScanDevice()
                
                var tempError:NSError = NSError()
                if self?.centerManager.manager.state == .poweredOff {
                    tempError = NSError(domain: "中心经理状态已关闭", code: bluetoothErrorState.bluetoothErrorStateNoReadly.rawValue, userInfo: nil)
                }
                let peripheral:TFYSwiftEasyPeripheral? = nil
                callback!(peripheral!,.searchFlagTypeFinish,tempError)
                return
            }
            
            if rule!(peripheral!) {
                let tempError:NSError = NSError()
                if searchType == .searchFlagTypeAdded {
                    self?.bluetoothState = .bluetoothStateDeviceFounded
                    if self?.bluetoothStateChanged != nil {
                        self?.bluetoothStateChanged!(peripheral,.bluetoothStateDeviceFounded)
                    }
                }
                callback!(peripheral!,searchType,tempError)
            }
            
        }
    }
    
    /// 在规定的时间内，搜索出所有符合条件的设备。
    /// 需要给定一个扫描时间，只有倒计时到这个时间时，才会回到所有扫描到的结果。（在EasyManagerOptions.h中给定时间）
    func scanAllDeviceWithName(name:String,callback:blueToothScanAllCallback?) {
        self.scanAllDeviceWithCondition(condition: name, callback: callback)
    }
    func scanAllDeviceWithRule(rule:blueToothScanRule?,callback:blueToothScanAllCallback?) {
        self.scanAllDeviceWithCondition(condition: rule, callback: callback)
    }
    
    /// 连接一个设备 （和下面的 扫描/连接 同时进行 需要区别 ）
    /// identifier 设备唯一ID <上一步扫描成功后，可以把这个ID保存到本地。然后在下一次连接的时候，可以直接拿这个ID来连接，省略了扫描一步>
    func connectDeviceWithIdentifier(identifier:String,callback:blueToothConnectCallback?) {
        let peripheral:TFYSwiftEasyPeripheral? = nil
        if identifier.isEmpty {
            let error:NSError = NSError(domain: "标识符为空！", code: bluetoothErrorState.bluetoothErrorStateIdentifierError.rawValue, userInfo: nil)
            callback!(peripheral!,error)
            return
        }
        let uuid:UUID = UUID(uuidString: identifier)!
        let UUIDString:String = uuid.uuidString
        if UUIDString.isEmpty {
            let error:NSError = NSError(domain: "标识符无效！", code: bluetoothErrorState.bluetoothErrorStateIdentifierError.rawValue, userInfo: nil)
            callback!(peripheral!,error)
            return
        }
        
        if self.centerManager.connectedDeviceDict[UUIDString] != nil {
            let error:NSError = NSError()
            let peripheral:TFYSwiftEasyPeripheral = self.centerManager.connectedDeviceDict[UUIDString] as! TFYSwiftEasyPeripheral
            callback!(peripheral,error)
        } else if self.centerManager.foundDeviceDict[UUIDString] != nil {
            let peripheral:TFYSwiftEasyPeripheral = self.centerManager.foundDeviceDict[UUIDString] as! TFYSwiftEasyPeripheral
            self.connectDeviceWithPeripheral(peripheral: peripheral, callback: callback!)
        } else {
            self.scanDeviceWithRule { peripheral in
                return (peripheral.identifierString?.contains(UUIDString))!
            } callback: { peripheral, error in
                if error != nil {
                    if callback != nil {
                        callback!(peripheral!,error)
                    }
                } else {
                    if peripheral == nil {
                        return
                    }
                    self.bluetoothState = .bluetoothStateDeviceFounded
                    if self.bluetoothStateChanged != nil {
                        self.bluetoothStateChanged!(peripheral,.bluetoothStateDeviceFounded)
                    }
                    self.connectDeviceWithPeripheral(peripheral: peripheral, callback: callback!)
                }
            }

        }
        
    }
    func connectDeviceWithPeripheral(peripheral:TFYSwiftEasyPeripheral?,callback: @escaping blueToothConnectCallback) {
        if peripheral == nil {
            return
        }
        let error:NSError = NSError()
        self.centerManager.connectedDeviceDict.values.forEach { tempP2 in
            let tempP:TFYSwiftEasyPeripheral = (tempP2 as! TFYSwiftEasyPeripheral)
            if tempP.isEqual(peripheral) {
                self.bluetoothState = .bluetoothStateDeviceConnected
                if self.bluetoothStateChanged != nil {
                    self.bluetoothStateChanged!(peripheral,.bluetoothStateDeviceConnected)
                }
                callback(peripheral,error)
                return
            }
        }
        
        peripheral?.connectDeviceWithTimeOut(timeout: self.managerOptions?.connectTimeOut, options: self.managerOptions?.connectOptions, callback: { [weak self] perpheral, error, type in
            
            switch type {
            case .deviceConnectTypeDisConnect:
                var errorCode:bluetoothErrorState = .bluetoothErrorStateDisconnect
                if self?.managerOptions?.autoConnectAfterDisconnect != nil {
                    peripheral?.reconnectDevice()
                    errorCode = .bluetoothErrorStateDisconnectTring
                }
                var tempError:NSError? = nil
                if error != nil {
                    tempError = NSError(domain: error!.localizedDescription, code: errorCode.rawValue, userInfo: nil)
                }
                callback(perpheral,tempError!)
                break
            case .deviceConnectTypeSuccess:
                self?.bluetoothState = .bluetoothStateDeviceConnected
                if self?.bluetoothStateChanged != nil {
                    self?.bluetoothStateChanged!(peripheral,.bluetoothStateDeviceConnected)
                }
                callback(peripheral,error)
                break
            case .deviceConnectTypeFaild:
                break
            case .deviceConnectTypeFaildTimeout:
                var tempError:NSError = NSError()
                if error != nil {
                    tempError = NSError(domain: error!.localizedDescription, code: bluetoothErrorState.bluetoothErrorStateConnectError.rawValue, userInfo: nil)
                }
                callback(peripheral,tempError)
                break
            }
        })
    }
    
    /// 扫描、连接同时进行，返回的是已经连接上的设备。一旦发现符合条件的设备就会停止搜索，然后直接连接，最后返回连接结果。
    func scanAndConnectDeviceWithName(name:String,callback:blueToothScanCallback?) {
        self.scanDeviceWithName(name: name) { peripheral, error in
            if error != nil {
                callback!(peripheral,error)
                return
            }
            if peripheral != nil {
                self.connectDeviceWithPeripheral(peripheral: peripheral, callback: callback!)
            }
        }
    }
    func scanAndConnectDeviceWithRule(rule:@escaping blueToothScanRule,callback:blueToothScanCallback?) {
        self.scanDeviceWithRule(rule: rule) { peripheral, error in
            if error != nil {
                callback!(peripheral,error)
            }
            if peripheral != nil {
                self.connectDeviceWithPeripheral(peripheral: peripheral, callback: callback!)
            }
        }
    }
    func scanAndConnectDeviceWithIdentifier(identifier:String,callback:blueToothScanCallback?) {
        self.connectDeviceWithIdentifier(identifier: identifier, callback: callback)
    }
    
    /// 连接已知名称的所有设备（返回的是一组此名称的设备全部连接成功）--->（慎用此功能）
    func scanAndConnectAllDeviceWithName(name:String,callback:blueToothScanAllCallback?) {
        self.scanAllDeviceWithName(name: name) { deviceArray, error in
            if deviceArray.count > 0 {
                self.dealScanedAllDeviceWithArray(deviceArray: deviceArray, error: error, callback: callback)
            } else {
                callback!([],error)
            }
        }
    }
    func scanAndConnectAllDeviceWithRule(rule:blueToothScanRule?,callback:blueToothScanAllCallback?) {
        self.scanAllDeviceWithRule(rule: rule) { [weak self] deviceArray, error in
            if deviceArray.count > 0 {
                self?.dealScanedAllDeviceWithArray(deviceArray: deviceArray, error: error, callback: callback)
            } else {
                callback!([],error)
            }
        }
    }
    
    /// 设备的读写操作。发送命令给硬件设备，从硬件设备中读取状态。注意：但是一般的硬件返回过来的数据会在notify中返回。
    func writeDataWithPeripheral(peripheral:TFYSwiftEasyPeripheral,serviceUUID:String,writeUUID:String,data:Data,callback:blueToothOperationCallback?) {
        self.searchCharacteristicWithPeripheral(peripheral: peripheral, serviceUUID: serviceUUID, operationUUID: writeUUID) { character, error in
            if error != nil {
                callback!(data,error)
                return
            }
            character?.writeValueWithData(data: data, callback: { characteristic, data, error in
                var tempError:NSError? = nil
                if error != nil {
                    tempError = NSError(domain: error!.localizedDescription, code: bluetoothErrorState.bluetoothErrorStateWriteError.rawValue, userInfo: nil)
                } else {
                    self.bluetoothState = .bluetoothStateWriteDataSuccess
                    if self.bluetoothStateChanged != nil {
                        self.bluetoothStateChanged!(peripheral,.bluetoothStateWriteDataSuccess)
                    }
                }
                callback!(data,tempError!)
            })
        }
    }
    func readValueWithPeripheral(peripheral:TFYSwiftEasyPeripheral,serviceUUID:String,readUUID:String,callback:blueToothOperationCallback?) {
        self.searchCharacteristicWithPeripheral(peripheral: peripheral, serviceUUID: serviceUUID, operationUUID: readUUID) { character, error in
            if error != nil {
                callback!(Data(),error)
                return
            }
            character?.readValueWithCallback(callback: { characteristic, data, error in
                var tempError:NSError? = nil
                if error != nil {
                    tempError = NSError(domain: error!.localizedDescription, code: bluetoothErrorState.bluetoothErrorStateReadError.rawValue, userInfo: nil)
                } else {
                    self.bluetoothState = .bluetoothStateReadSuccess
                    if self.bluetoothStateChanged != nil {
                        self.bluetoothStateChanged!(peripheral,.bluetoothStateReadSuccess)
                    }
                }
                callback!(data,tempError!)
            })
        }
    }
    
    /// 监听这个设备硬件返回过来的数据， (建议此方法放在读写操作的前面)
    func notifyDataWithPeripheral(peripheral:TFYSwiftEasyPeripheral,serviceUUID:String,notifyUUID:String,notifyValue:Bool,callback:blueToothOperationCallback?) {
        self.searchCharacteristicWithPeripheral(peripheral: peripheral, serviceUUID: serviceUUID, operationUUID: notifyUUID) { character, error in
            if error != nil {
                callback!(Data(),error)
                return
            }
            character?.notifyWithValue(value: notifyValue, callback: { characteristic, data, error in
                var tempError:NSError? = nil
                if error != nil {
                    tempError = NSError(domain: error!.localizedDescription, code: bluetoothErrorState.bluetoothErrorStateNotifyError.rawValue, userInfo: nil)
                } else {
                    self.bluetoothState = .bluetoothStateNotifySuccess
                    if self.bluetoothStateChanged != nil {
                        self.bluetoothStateChanged!(peripheral,.bluetoothStateNotifySuccess)
                    }
                }
                callback!(data,tempError!)
            })
        }
    }
    
    /// 对描述进行操作。
    func writeDescriptorWithPeripheral(peripheral:TFYSwiftEasyPeripheral,serviceUUID:String,characterUUID:String,data:Data,callback:blueToothOperationCallback?) {
        self.searchCharacteristicWithPeripheral(peripheral: peripheral, serviceUUID: serviceUUID, operationUUID: characterUUID) { character, error in
            if error != nil {
                callback!(data,error)
                return
            }
            if (character?.descriptorArray.count)! > 0 {
                character?.descriptorArray.forEach({ tempD in
                    tempD.writeValueWithData(data: data) { descriptor, error in
                        callback!(descriptor.value,error)
                    }
                })
            } else {
                let tempError:NSError = NSError(domain: "特点无说明", code: bluetoothErrorState.bluetoothErrorStateNoDescriptor.rawValue, userInfo: nil)
                callback!(data,tempError)
            }
        }
    }
    func readDescriptorWithPeripheral(peripheral:TFYSwiftEasyPeripheral,serviceUUID:String,characterUUID:String,callback:blueToothOperationCallback?) {
        self.searchCharacteristicWithPeripheral(peripheral: peripheral, serviceUUID: serviceUUID, operationUUID: characterUUID) { character, error in
            if error != nil {
                callback!(Data(),error)
                return
            }
            if (character?.descriptorArray.count)! > 0 {
                character?.descriptorArray.forEach({ tempD in
                    tempD.readValueWithCallback { descriptor, error in
                        callback!(descriptor.value,error)
                    }
                })
            } else {
                let tempError:NSError = NSError(domain: "特点无说明", code: bluetoothErrorState.bluetoothErrorStateNoDescriptor.rawValue, userInfo: nil)
                callback!(Data(),tempError)
            }
        }
    }
    
    /// 读取设备的rssi
    func readRSSIWithPeripheral(peripheral:TFYSwiftEasyPeripheral,callback:TFYSwiftEasyPeripheral.blueToothReadRSSICallback?) {
        peripheral.readDeviceRSSIWithCallback { peripheral, RSSI, error in
            callback!(peripheral,RSSI,error)
        }
    }
    
    /// 主动 开始/停止 扫描
    func startScanDevice() {
        self.centerManager.startScanDevice()
    }
    func stopScanDevice() {
        self.centerManager.stopScanDevice()
    }
    
    /// 主动断开已经连接成功的设备操作
    func disconnectWithPeripheral(peripheral:TFYSwiftEasyPeripheral) {
        peripheral.disconnectDevice()
    }
    func disconnectWithIdentifier(identifier:UUID) {
        let tempPeripheral:TFYSwiftEasyPeripheral? = (self.centerManager.connectedDeviceDict[identifier.uuidString] as! TFYSwiftEasyPeripheral)
        if tempPeripheral != nil {
            tempPeripheral?.disconnectDevice()
        }
    }
    func disconnectAllPeripheral() {
        self.centerManager.disConnectAllDevice()
    }
    
    /// 这里面包含的过程 扫描设备--->连接设备--->发现服务--->发现特征--->监听特征--->写命令数据--->返回数据
    /// 最好还监听bluetoothState这个参数的变化。可以用来判断蓝牙到底进行到哪个地方了。
    func connectDeviceWithName(name:String,serviceUUID:String,notifyUUID:String,writeUUID:String,data:Data?,callback:blueToothOperationCallback?) {
        self.scanAndConnectDeviceWithName(name: name) { peripheral, error in
            if error == nil {
                self.notifyDataWithPeripheral(peripheral: peripheral!, serviceUUID: serviceUUID, notifyUUID: notifyUUID, notifyValue: true) { data, error in
                    callback!(data,error)
                }
                
                if data != nil {
                    self.writeDataWithPeripheral(peripheral: peripheral!, serviceUUID: serviceUUID, writeUUID: writeUUID, data: data!) { data, error in
                        callback!(data,error)
                    }
                }
            } else {
                callback!(Data(),error)
            }
        }
    }
   
    func scanDeviceWithCondition(condition:Any?,callback:blueToothScanCallback?) {
        let peripheral:TFYSwiftEasyPeripheral? = nil
        if condition == nil {
            let tempError:NSError = NSError(domain: "条件为零", code: bluetoothErrorState.bluetoothErrorStateNoDevice.rawValue, userInfo: nil)
            callback!(peripheral!,tempError)
        }
        if self.centerManager.manager.state == .poweredOn {
            self.bluetoothState = .bluetoothStateSystemReadly
            let peripheral:TFYSwiftEasyPeripheral? = nil
            if self.bluetoothStateChanged != nil {
                self.bluetoothStateChanged!(peripheral!,.bluetoothStateSystemReadly)
            }
        } else if self.centerManager.manager.state == .poweredOff {
            let tempError:NSError = NSError(domain: "中心经理状态已关闭，并准备开启！", code: bluetoothErrorState.bluetoothErrorStateNoReadlyTring.rawValue, userInfo: nil)
            callback!(peripheral!,tempError)
        }
        
        self.centerManager.scanDeviceWithTimeInterval(timeInterval: self.managerOptions?.scanTimeOut, service: self.managerOptions?.scanServiceArray, options: self.managerOptions?.scanOptions) { [weak self] peripheral, searchType in
            
            print("外围设备 - \(String(describing: peripheral?.name))-identifierString:\(String(describing: peripheral?.identifierString))-检索类别 - \(searchType)")
            
            if searchType == .searchFlagTypeFinish {//扫描完成
                self?.centerManager.stopScanDevice()
                
                var tempError:NSError? = nil
                if self?.centerManager.manager.state == .poweredOff {
                    tempError = NSError(domain: "中心经理状态已关闭", code: bluetoothErrorState.bluetoothErrorStateNoReadly.rawValue, userInfo: nil)
                } else {
                    tempError = NSError(domain: "没有找到设备 ！", code: bluetoothErrorState.bluetoothErrorStateNoDevice.rawValue, userInfo: nil)
                }
                callback!(peripheral,tempError!)
                return
            }
            
            if condition is String {
                let name:String = condition as! String
                if (peripheral!.name?.contains(name))! && searchType == .searchFlagTypeAdded {
                    self?.centerManager.stopScanDevice()
                    
                    self?.bluetoothState = .bluetoothStateDeviceFounded
                    if self?.bluetoothStateChanged != nil {
                        self?.bluetoothStateChanged!(peripheral,.bluetoothStateDeviceFounded)
                    }
                    let tempError:NSError = NSError()
                    callback!(peripheral,tempError)
                }
            } else {
                let rule:blueToothScanRule = condition as! blueToothScanRule
                if rule(peripheral!) && searchType == .searchFlagTypeAdded {
                    self?.centerManager.stopScanDevice()
                    
                    self?.bluetoothState = .bluetoothStateDeviceFounded
                    if self?.bluetoothStateChanged != nil {
                        self?.bluetoothStateChanged!(peripheral,.bluetoothStateDeviceFounded)
                    }
                    let tempError:NSError = NSError()
                    callback!(peripheral,tempError)
                }
            }
        }
    }
    
    func scanAllDeviceWithCondition(condition:Any?,callback:blueToothScanAllCallback?) {
        if self.managerOptions?.scanTimeOut == NSIntegerMax {
            self.managerOptions?.scanTimeOut = 20
        }
        var tempArray:[TFYSwiftEasyPeripheral] = [TFYSwiftEasyPeripheral]()
        self.centerManager.scanDeviceWithTimeInterval(timeInterval: self.managerOptions?.scanTimeOut, service: self.managerOptions?.scanServiceArray, options: self.managerOptions?.scanOptions) { [weak self] peripheral, searchType in
            
            if searchType == .searchFlagTypeFinish {
                self?.centerManager.stopScanDevice()
                var tempError:NSError = NSError()
                if self?.centerManager.manager.state == .poweredOff {
                    tempError = NSError(domain: "中心经理状态已关闭", code: bluetoothErrorState.bluetoothErrorStateNoReadly.rawValue, userInfo: nil)
                } else {
                    if tempArray.count == 0 {
                        tempError = NSError(domain: "没有找到设备 ！", code: bluetoothErrorState.bluetoothErrorStateNoDevice.rawValue, userInfo: nil)
                    }
                }
                callback!(tempArray,tempError)
                return
            }
            
            if condition is String {
                let name:String = condition as! String
                if ((peripheral!.name?.contains(name)) != nil) {
                    let isEixt:Bool = self!.isExitObject(peripheral: peripheral!, tempArray: tempArray)
                    if !isEixt {
                        if !tempArray.contains(peripheral!) {
                            tempArray.append(peripheral!)
                        }
                    }
                }
            } else {
                let rule:blueToothScanRule = condition as! blueToothScanRule
                if rule(peripheral!) {
                    let isEixt:Bool = self!.isExitObject(peripheral: peripheral!, tempArray: tempArray)
                    if !isEixt {
                        if !tempArray.contains(peripheral!) {
                            tempArray.append(peripheral!)
                        }
                    }
                }
            }
        }
    }
    
    func isExitObject(peripheral:TFYSwiftEasyPeripheral,tempArray:[Any]) -> Bool {
        var isExited:Bool = false
        for (_,obj) in tempArray.enumerated() {
            if obj is TFYSwiftEasyPeripheral {
                let tempP:TFYSwiftEasyPeripheral = (obj as! TFYSwiftEasyPeripheral)
                if tempP.identifier.uuidString.contains(peripheral.identifierString!) {
                    isExited = true
                    break
                }
            }
        }
        return isExited
        
    }
    
    func dealScanedAllDeviceWithArray(deviceArray:[TFYSwiftEasyPeripheral],error:Error?,callback:blueToothScanAllCallback?) {
        for (index,_) in deviceArray.enumerated() {
            TFYSwiftAsynce.asyncDelay(Double(index) * 0.3) {
                let tempPeripheral:TFYSwiftEasyPeripheral = deviceArray[index]
                self.connectDeviceWithPeripheral(peripheral: tempPeripheral) { peripheral, error in
                    if error == nil {
                        peripheral?.connectErrorDescription = error
                    }
                    if index == (deviceArray.count - 1) {
                        callback!(deviceArray,error)
                    }
                }
            }
        }
    }
    
    func searchCharacteristicWithPeripheral(peripheral:TFYSwiftEasyPeripheral?,serviceUUID:String,operationUUID:String,callback: blueToothFindCharacteristic?)  {

        let serviceuuid:CBUUID = CBUUID(string: serviceUUID)
        let operationuuid:CBUUID = CBUUID(string: operationUUID)
        
        if peripheral?.state != .connected {
            let error:NSError = NSError(domain: "设备未连接！连接后请操作！", code: bluetoothErrorState.bluetoothErrorStateNoConnect.rawValue, userInfo: nil)
            callback!(nil,error)
        }
        
        peripheral?.discoverAllDeviceServiceWithCallback(uuidArray: [serviceuuid], callback: { peripheral, serviceArray, error in
            var exitedService:TFYSwiftEasyService? = nil
            serviceArray.forEach { tempService in
                if tempService.UUID.isEqual(serviceuuid) {
                    exitedService = tempService
                }
            }
            
            if exitedService != nil {
                self.bluetoothState = .bluetoothStateServiceFounded
                if self.bluetoothStateChanged != nil {
                    self.bluetoothStateChanged!(peripheral,.bluetoothStateServiceFounded)
                }
                
                exitedService?.discoverCharacteristicWithCharacteristicUUIDs(uuidArray: [operationuuid], callback: { characteristics, error in
                    var exitedCharacter:TFYSwiftEasyCharacteristic? = nil
                    characteristics.forEach { tempCharacter in
                        exitedCharacter = tempCharacter
                    }
                    
                    if exitedCharacter != nil {
                        self.bluetoothState = .bluetoothStateCharacterFounded
                        if self.bluetoothStateChanged != nil {
                            self.bluetoothStateChanged!(peripheral,.bluetoothStateCharacterFounded)
                        }
                        callback!(exitedCharacter,error)
                    } else {
                        let error:NSError = NSError(domain: "您提供的服务uuid​​不会退出！", code: bluetoothErrorState.bluetoothErrorStateNoCharcter.rawValue, userInfo: nil)
                        callback!(nil,error)
                    }
                })
            } else {
                let error:NSError = NSError(domain: "您提供的服务uuid​​不会退出！", code: bluetoothErrorState.bluetoothErrorStateNoService.rawValue, userInfo: nil)
                callback!(nil,error)
            }
        })
    }
    
    
}


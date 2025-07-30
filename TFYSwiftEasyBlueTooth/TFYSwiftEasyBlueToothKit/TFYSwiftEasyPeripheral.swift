//
//  TFYSwiftEasyPeripheral.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import UIKit
import CoreBluetooth

public enum deviceConnectType:Int {
    /// 设备连接成功
    case deviceConnectTypeSuccess = 0
    /// 设备连接失败
    case deviceConnectTypeFaild = 1
    /// 设备连接失败（原因：连接超时）
    case deviceConnectTypeFaildTimeout = 2
    /// 设备断开连接
    case deviceConnectTypeDisConnect = 3
}

public class TFYSwiftEasyPeripheral: NSObject {
    
    private var connectTimeOut:Int? = 5 //连接设备超时时间
    private var connectOpertion:[String:Any]? = nil //需要连接设备所遵循的条件
    private var isReconnectDevice:Bool = true //用来处理发起连接时的参数问题。因为没调用连接一次，只能返回一次连接结果。
    private var blueToothReadRSSICallback:blueToothReadRSSICallback? //读取rssi回调结果

    //设备发现服务回调
    private var findServiceCallbackArray:[blueToothFindServiceCallback] = [blueToothFindServiceCallback]()
    
    /// 连接设备回调
    typealias blueToothConnectDeviceCallback = (_ perpheral:TFYSwiftEasyPeripheral?,_ error:Error?,_ type:deviceConnectType) -> Void
    /// 读取RSSI回调，次回掉之后会一次返回结果
    typealias blueToothReadRSSICallback = (_ peripheral:TFYSwiftEasyPeripheral,_ RSSI:NSNumber,_ error:Error?) -> Void
    /// 寻找设备中的服务回掉
    typealias blueToothFindServiceCallback = (_ peripheral:TFYSwiftEasyPeripheral,_ serviceArray:[TFYSwiftEasyService],_ error:Error?) -> Void
    
    /// 系统提供出来的当前设备
    var peripheral:CBPeripheral?
    
    /// 设备名称
    var name: String? {
        guard let localName = self.peripheral?.name else {
            return "无名称"
        }
        return localName
    }
    
    /// 设备的唯一ID
    var identifier: UUID { 
        guard let peripheral = self.peripheral else {
            return UUID()
        }
        return peripheral.identifier 
    }
    
    var identifierString:String? { self.peripheral?.identifier.uuidString }
    
    /// 设备当前的中心管理者
    var centerManager:TFYSwiftEasyCenterManager?
    
    /// 设备被扫描到的次数
    var deviceScanCount:Int = 0 {
        didSet {
            TFYSwiftAsynce.async { [weak self] in
                guard let self = self else { return }
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.devicenotFoundTimeout), object: nil)
                self.perform(#selector(self.devicenotFoundTimeout), with: self, afterDelay: 5)
            }
        }
    }
    
    /// 设备的rssi
    var RSSI:NSNumber?
    
    /// 设备当前的广播数据
    var advertisementData:[String:Any] = [String:Any]()
    
    /// 当前是否连接成功
    var isConnected: Bool {
        guard let peripheral = self.peripheral else { return false }
        return peripheral.state == .connected
    }
    
    /// 当前设备状态
    var state:CBPeripheralState { 
        guard let peripheral = self.peripheral else { return .disconnected }
        return peripheral.state 
    }
    
    /// 当前设备的错误信息
    var connectErrorDescription:Error?
    
    /// 设备中所有的服务
    var serviceArray:[TFYSwiftEasyService] = [TFYSwiftEasyService]()
    
    /// 连接设备回调
    var connectCallback:blueToothConnectDeviceCallback?
    
    /// 连接超时定时器
    private var connectTimer:DispatchWorkItem?
    
    init(peripheral:CBPeripheral,manager:TFYSwiftEasyCenterManager) {
        super.init()
        
        self.centerManager = manager
        self.peripheral = peripheral
        peripheral.delegate = self
        
        self.connectTimeOut = 5
        self.isReconnectDevice = true
        
        self.perform(#selector(self.devicenotFoundTimeout), with: self, afterDelay: 5)
    }
    
    /// 连接一个设备
    func connectDeviceWithTimeOut(timeout:Int? = 5,options:[String:Any]? = nil,callback: blueToothConnectDeviceCallback?) {
        if callback != nil {
            connectCallback = callback
        } else {
            print("您应该处理连接设备回调！")
        }
        connectTimeOut = timeout
        connectOpertion = options
        isReconnectDevice = true
        
        if self.peripheral?.state == .connected {
            print("注意！设备已正确连接！")
            self.disconnectDevice()
        }
        print("\(String(format: "开始连接设备 - 时间长度%ld", timeout!))")
        self.centerManager?.manager.connect(self.peripheral!, options: options)
        
        //如果设定的时间内系统没有回调连接的结果。直接返回错误信息
        connectTimer = TFYSwiftAsynce.asyncDelay(Double(self.connectTimeOut!)) { [weak self] in
            guard let self = self else { return }
            if !self.isReconnectDevice {
                return
            }
            let error:NSError = NSError(domain: "连接设备超时 ~~", code: -101, userInfo: nil)
            if self.connectCallback != nil {
                self.connectCallback!(self,error,deviceConnectType.deviceConnectTypeFaildTimeout)
            }
            self.isReconnectDevice = false
            self.disconnectDevice()
        }
    }
    
    /// 如果设备失去连接，调用此方法 再次连接设备(会保留上一次调用的参数)
    func reconnectDevice() {
        self.isReconnectDevice = true
        self.connectDeviceWithTimeOut(timeout: connectTimeOut, options: connectOpertion, callback: connectCallback)
    }
    
    /// 主动断开设备连接，（不会回调设备失去连接的方法）
    func disconnectDevice() {
        // 取消连接超时定时器
        if let timer = connectTimer {
            TFYSwiftAsynce.cancelDelay(timer)
            connectTimer = nil
        }
        
        if self.state == .connected {
            self.centerManager?.manager.cancelPeripheralConnection(self.peripheral!)
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self.centerManager?.manager as Any, selector: #selector(self.centerManager?.manager.connect(_:options:)), object: self.connectOpertion)
    }
    
    /// 重置设备被发现次数
    func resetDeviceScanCount() {
        self.deviceScanCount = -1
    }
    
    @objc func devicenotFoundTimeout() {
        self.centerManager?.foundDeviceTimeout(perpheral: self)
    }
   
    /// 读取设备的RSSI
    func readDeviceRSSIWithCallback(callback:blueToothReadRSSICallback?) {
        if callback != nil {
            self.blueToothReadRSSICallback = callback
        } else {
            print("你应该处理回调")
        }
        self.peripheral?.readRSSI()
    }
    
    /// 处理manager连接设备的结果。
    func dealDeviceConnectWithError(error:Error?,type:deviceConnectType) {
        // 取消连接超时定时器
        if let timer = connectTimer {
            TFYSwiftAsynce.cancelDelay(timer)
            connectTimer = nil
        }
        
        self.isReconnectDevice = false
        if connectCallback != nil {
            connectCallback!(self,error,type)
        }
    }
    
    /// 设备中所有的服务
    func searchServiceWithService(service:CBService?) -> TFYSwiftEasyService? {
        guard let service = service else { return nil }
        var tempService:TFYSwiftEasyService?
        for (_,tempS) in self.serviceArray.enumerated() {
            if tempS.UUID.isEqual(service.uuid) {
                tempService = tempS
                break
            }
        }
        return tempService
    }
    
    /// 查找设备中的所有服务
    func discoverAllDeviceServiceWithCallback(uuidArray:[CBUUID] = [CBUUID](),callback:blueToothFindServiceCallback?) {
        if callback != nil {
            self.findServiceCallbackArray.append(callback!)
        } else {
            print("你应该处理回调")
        }
        var isAllUUIDExited:Bool = uuidArray.count > 0 ? true:false //需要查找的UUID是否都存在
        uuidArray.forEach { tempUUID in
            var isExitedUUID:Bool = false
            for (_,tempSerevice) in self.serviceArray.enumerated() {
                if tempSerevice.UUID.isEqual(tempUUID) {
                    isExitedUUID = true
                    break
                }
            }
            if !isExitedUUID {
                isAllUUIDExited = false
            }
        }
        if isAllUUIDExited {
            if self.findServiceCallbackArray.count > 0 {
                let callback:blueToothFindServiceCallback? = self.findServiceCallbackArray.first
                callback?(self,self.serviceArray,nil)
                self.findServiceCallbackArray.remove(at: 0)
            }
        } else {
            print("\(String(format: "寻找设备上的服务 %@", self.peripheral!.identifier.uuidString))")
            self.peripheral?.discoverServices(uuidArray)
        }
    }
    
    deinit {
        disconnectDevice()
        self.peripheral = nil
        self.peripheral?.delegate = nil
        self.centerManager = nil
        self.findServiceCallbackArray.removeAll()
        self.serviceArray.removeAll()
    }
}

extension TFYSwiftEasyPeripheral:CBPeripheralDelegate {
    
    /// CBPeripheralDelegate Methods
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("uuidString:\(peripheral.identifier.uuidString)=设备的rssi读取:\(RSSI)==error:\(String(describing: error))")
        self.RSSI = RSSI
        if self.blueToothReadRSSICallback != nil {
            self.blueToothReadRSSICallback!(self,RSSI,error)
        }
    }
    
    /// 发现外设的服务
    ///
    /// - Parameters:
    ///   - peripheral: 外设
    ///   - error: 错误
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("uuidString==:\(peripheral.identifier.uuidString)=设备发现服务%@ serviceArray:\(String(describing: peripheral.services))==error:\(String(describing: error))")
        
        peripheral.services?.forEach({ tempService in
            let tempS:TFYSwiftEasyService? = self.searchServiceWithService(service: tempService)
            if tempS == nil {
                let easyS:TFYSwiftEasyService = TFYSwiftEasyService(service: tempService, perpheral: self)
                self.serviceArray.append(easyS)
            }
        })
        if self.findServiceCallbackArray.count > 0 {
            let callback:blueToothFindServiceCallback? = self.findServiceCallbackArray.first
            callback?(self,self.serviceArray,error)
            self.findServiceCallbackArray.remove(at: 0)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("uuidString:\(peripheral.identifier.uuidString)=已连接上行的设备发现了服务%@ serviceArray:\(String(describing: peripheral.services))=error:\(String(describing: error))")
    }
    
    /// 发现外设的特征,订阅特征(读、写等)
    ///
    /// - Parameters:
    ///   - peripheral: 外设
    ///   - service: 外设的w服务
    ///   - error: 错误
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("=uuid:\(service.uuid)=发现了服务上的特征 %@ characterArray:\(String(describing: service.characteristics))=error:\(String(describing: error))")
        let tempService:TFYSwiftEasyService? = self.searchServiceWithService(service: service)
        if tempService != nil {
            tempService?.dealDiscoverCharacteristic(characteristics: service.characteristics, error: error)
        } else {
            print("你应该解决这个错误")
        }
    }
    
    /// 收到外设发送内容
   ///
   /// - Parameters:
   ///   - peripheral: 外设
   ///   - characteristic: 特征
   ///   - error: 错误
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("==uuid:\(characteristic.uuid)=特征上的数据更新:value:\(String(describing: characteristic.value))=error:\(String(describing: error))")
        let tempService:TFYSwiftEasyService? = self.searchServiceWithService(service: characteristic.service)
        if tempService != nil {
            let character:TFYSwiftEasyCharacteristic? = tempService!.searchCharacteristciWithCharacteristic(characteristic: characteristic)
            if (character?.isNotifying ?? false) {
                character?.dealOperationCharacterWithType(type: .OperationTypeNotify, error: error)
            } else {
                character?.dealOperationCharacterWithType(type: .OperationTypeRead, error: error)
            }
        }
    }
    
    //当特征注册通知后 会回调此方法
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("监听 特征的回调:==uuid:\(characteristic.uuid)=error:\(String(describing: error))")
        let easyService:TFYSwiftEasyService? = self.searchServiceWithService(service: characteristic.service)
        let character:TFYSwiftEasyCharacteristic? = easyService?.searchCharacteristciWithCharacteristic(characteristic: characteristic)
        character?.dealOperationCharacterWithType(type: .OperationTypeNotify, error: error)
    }
    
    // 当写入某个特征值后 外设代理执行的回调
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("写 特征的回调==uuid:\(characteristic.uuid)==error:\(String(describing: error))")
        let tempService:TFYSwiftEasyService? = searchServiceWithService(service: characteristic.service)
        if tempService != nil {
            let character:TFYSwiftEasyCharacteristic? = tempService?.searchCharacteristciWithCharacteristic(characteristic: characteristic)
            character?.dealOperationCharacterWithType(type: .OperationTypeWrite, error: error)
        }
    }
    
    // descriptor
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("发现特征上的描述==uuid:\(characteristic.uuid)=descriptors:\(String(describing: characteristic.descriptors))=error:\(String(describing: error))")
        let easyService:TFYSwiftEasyService? = searchServiceWithService(service: characteristic.service)
        if easyService != nil {
            let character:TFYSwiftEasyCharacteristic? = easyService?.searchCharacteristciWithCharacteristic(characteristic: characteristic)
            character?.dealDiscoverDescriptorWithError(error: error)
        }
    }
    
    //获取到Descriptors的值
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("获取到Descriptors的值=uuid:\(descriptor.uuid)==value:\(String(describing: descriptor.value))")
        //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
        self.serviceArray.forEach({ tempS in
            tempS.characteristicArray.forEach({ tempC in
                tempC.descriptorArray.forEach { tempD in
                    if tempD.descroptor?.isEqual(descriptor) == true {
                        tempD.dealOperationDescriptorWithType(type: .OperationTypeRead, eroor: error)
                        return
                    }
                }
            })
        })
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("写 特征上的描述的回调=: \(descriptor.uuid)==error:\(String(describing: error))")
        self.serviceArray.forEach({ tempS in
            tempS.characteristicArray.forEach({ tempC in
                tempC.descriptorArray.forEach { tempD in
                    if tempD.descroptor?.isEqual(descriptor) == true {
                        tempD.dealOperationDescriptorWithType(type: .OperationTypeWrite, eroor: error)
                    }
                }
            })
        })
    }
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("peripheralDidUpdateName=:\(String(describing: peripheral.name))")
    }
}

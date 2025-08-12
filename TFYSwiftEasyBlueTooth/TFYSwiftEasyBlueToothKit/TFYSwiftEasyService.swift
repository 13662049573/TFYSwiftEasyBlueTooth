//
//  TFYSwiftEasyService.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import UIKit
import CoreBluetooth

public class TFYSwiftEasyService: NSObject {

    /// 发现服务上的特征回调
    typealias blueToothFindCharacteristicCallback = (_ characteristics:[TFYSwiftEasyCharacteristic] , _ error:Error?) -> Void
    
    /// 服务名称
    var name: String { 
        guard let service = self.service else { return "Unknown Service" }
        return service.uuid.uuidString 
    }
    
    ///  系统提供出来的服务
    var service:CBService?
    
    var includedServices:[CBService] { 
        guard let service = self.service else { return [] }
        return service.includedServices ?? []
    }
    
    /// 服务的唯一标示
    var UUID: CBUUID { 
        guard let service = self.service else { return CBUUID() }
        return service.uuid 
    }
    
    /// 服务是否是开启状态
    var isOn:Bool = true
    
    /// 服务是否是可用状态
    var isEnabled:Bool = true
    
    /// 服务所在的设备
    var peripheral:TFYSwiftEasyPeripheral?
    
    /// 服务中所有的特征
    var characteristicArray:[TFYSwiftEasyCharacteristic] = [TFYSwiftEasyCharacteristic]()
    
    private var findCharacterCallbackArray:[blueToothFindCharacteristicCallback] = [blueToothFindCharacteristicCallback]()
    
    /// 初始化方法
    init(service:CBService,perpheral:TFYSwiftEasyPeripheral) {
        super.init()
        
        self.peripheral = perpheral
        self.service = service
        self.isOn = true
        self.isEnabled = true
    }
    
    /// 查找服务中所有的特征
    func searchCharacteristciWithCharacteristic(characteristic:CBCharacteristic) -> TFYSwiftEasyCharacteristic? {
        var tempC:TFYSwiftEasyCharacteristic?
        for (_,tCharacterstic) in self.characteristicArray.enumerated() {
            if characteristic.uuid.isEqual(tCharacterstic.UUID) {
                tempC = tCharacterstic
                break
            }
        }
        return tempC
    }
    
    /// 查找服务上的特征
    func discoverCharacteristicWithCharacteristicUUIDs(uuidArray:[CBUUID] = [],callback: blueToothFindCharacteristicCallback?) {
        if callback != nil {
            self.findCharacterCallbackArray.append(callback!)
        }
        var isAllUUIDExited:Bool = uuidArray.count > 0 ? true:false //需要查找的UUID是否都存在
        uuidArray.forEach { tempUUID in
            var isExitedUUID:Bool = false //数组里单个需要查找到UUID是否存在
            for (_,tempCharacter) in self.characteristicArray.enumerated() {
                if tempCharacter.UUID?.isEqual(tempUUID) == true {
                    isExitedUUID = true
                    break
                }
            }
            if !isExitedUUID {
                isAllUUIDExited = false
            }
        }
        
        if isAllUUIDExited {
            if self.findCharacterCallbackArray.count > 0 {
                let callback:blueToothFindCharacteristicCallback = self.findCharacterCallbackArray.first!
                callback(self.characteristicArray,nil)
                self.findCharacterCallbackArray.remove(at: 0)
            }
        } else {
            guard let peripheral = self.peripheral?.peripheral, let service = self.service else {
                let error = NSError(domain: "设备或服务为空", code: -1, userInfo: nil)
                callback?([], error)
                return
            }
            peripheral.discoverCharacteristics(uuidArray, for: service)
        }
    }
    
    /// 处理manager的连接结果
    func dealDiscoverCharacteristic(characteristics:[CBCharacteristic]?,error:Error?) {
        if characteristics != nil {
            characteristics!.forEach { tempCharacteristic in
                let tempC:TFYSwiftEasyCharacteristic? = self.searchCharacteristciWithCharacteristic(characteristic: tempCharacteristic)
                if tempC == nil {
                    let character:TFYSwiftEasyCharacteristic = TFYSwiftEasyCharacteristic.init(character: tempCharacteristic, peripheral: self.peripheral!)
                    self.characteristicArray.append(character)
                }
            }
            
            if self.findCharacterCallbackArray.count > 0 {
                let callback:blueToothFindCharacteristicCallback = self.findCharacterCallbackArray.first!
                callback(self.characteristicArray,error)
                
                self.findCharacterCallbackArray.remove(at: 0)
            }
        }
    }
    
    deinit {
        self.service = nil
        self.peripheral = nil
        self.characteristicArray.removeAll()
        self.findCharacterCallbackArray.removeAll()
    }
}

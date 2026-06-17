//
//  TFYSwiftEasyCharacteristic.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import UIKit
import CoreBluetooth

public enum OperationType:Int {
    case OperationTypeWrite = 0
    case OperationTypeRead = 1
    case OperationTypeNotify = 2
}

public class TFYSwiftEasyCharacteristic: NSObject {
    /// 往特征上操作数据
    public typealias blueToothCharactersticOperateCallback = (_ characteristic:TFYSwiftEasyCharacteristic,_ data:Data?,_ error:Error?) -> Void
    /// 查找到特征上的描述回调
    public typealias blueToothFindDescriptorCallback = (_ descriptorArray:[TFYSwiftEasyDescriptor],_ error:Error?) -> Void

    private var blueToothFindDescriptorCallback:blueToothFindDescriptorCallback? //查询完descripter后的回调
    private var writeOperateCallback:blueToothCharactersticOperateCallback?
    private var readOperateCallback:blueToothCharactersticOperateCallback?
    private var notifyOperateCallback:blueToothCharactersticOperateCallback?
    private var readCallbackArray:[blueToothCharactersticOperateCallback] = [blueToothCharactersticOperateCallback]()
    private var writeCallbackArray:[blueToothCharactersticOperateCallback] = [blueToothCharactersticOperateCallback]()
    private var notifyCallbackArray:[blueToothCharactersticOperateCallback] = [blueToothCharactersticOperateCallback]()

    /// 特征名称
    public var name:String? { self.characteristic?.uuid.uuidString }

    /// 特征的唯一标示
    public var UUID: CBUUID? { self.characteristic?.uuid }

    /// 系统提供的特此
    public var characteristic:CBCharacteristic?

    /// 特征所属的服务
    public var service:TFYSwiftEasyService?

    /// 特征所属的设备
    public var peripheral:TFYSwiftEasyPeripheral?

    /// 特征上所有的特性
    public var properties:CBCharacteristicProperties {
        guard let characteristic = self.characteristic else { return CBCharacteristicProperties() }
        return CBCharacteristicProperties(rawValue: characteristic.properties.rawValue)
    }

    public var propertiesString:String {
        let temProperties:CBCharacteristicProperties = self.properties
        let tempString:NSMutableString = NSMutableString()
        switch temProperties {
           case .broadcast :
            tempString.append("Broadcast")
            break
        case .writeWithoutResponse:
            tempString.append("WithoutResponse")
            break
        case .read:
            tempString.append("Read")
            break
        case .write:
            tempString.append("Write")
            break
        case .notify:
            tempString.append("Notify")
            break
        case .indicate:
            tempString.append("Indicate")
            break
        case .authenticatedSignedWrites:
            tempString.append("AuthenticatedSignedWrites")
            break
        case [.notify, .indicate]:
            tempString.append("Notify,indicate")
            break
        case [.write,.writeWithoutResponse]:
            tempString.append("Write,WithoutResponse")
            break
        case [.read, .writeWithoutResponse, .notify]:
            tempString.append("Write,WithoutResponse,Notify")
            break
        case [.read, .writeWithoutResponse, .write, .notify, .indicate]:
            tempString.append("read,WithoutResponse,write,notify,indicate")
            break
        default://
            tempString.append("\(temProperties)")
            break
        }
        return tempString as String
    }

    /// 所包含的数据
    public var value:Data? {self.characteristic?.value}

    ///  是否正在监听数据
    public var isNotifying:Bool? { characteristic?.isNotifying }

    /// 特征中所有的描述
    public var descriptorArray:[TFYSwiftEasyDescriptor] = [TFYSwiftEasyDescriptor]()

    /// 接收到的数据都在这个数组里面，记录最后5次的操作
    @objc public dynamic var readDataArray:[Data] = [Data]()
    @objc public dynamic var writeDataArray:[Data] = [Data]()
    @objc public dynamic var notifyDataArray:[Data] = [Data]()


    /// 初始化方法
    public init(character:CBCharacteristic?,peripheral:TFYSwiftEasyPeripheral) {
        super.init()

        self.characteristic = character
        self.peripheral = peripheral
    }

    /// 处理 easyPeripheral操作完的回到
    public func dealOperationCharacterWithType(type:OperationType,error:Error?) {
        switch type {
        case .OperationTypeWrite:
            if self.writeOperateCallback != nil {
                self.writeOperateCallback!(self,self.value,error)
            }
        case .OperationTypeRead:
            if self.readOperateCallback != nil {
                self.readOperateCallback!(self,self.value,error)
            }
            if self.characteristic?.value != nil {
                self.addDataToArrayWithType(type: .OperationTypeRead, data: self.value)
            }
        case .OperationTypeNotify:
            if self.notifyOperateCallback != nil {
                self.notifyOperateCallback!(self,self.value,error)
            }
            if self.characteristic?.value != nil {
                self.addDataToArrayWithType(type: .OperationTypeNotify, data: self.value)
            }
        }
    }

    /// 操作characteristic
    public func writeValueWithData(data:Data?,callback:blueToothCharactersticOperateCallback?) {
        if let data = data {
            self.addDataToArrayWithType(type: .OperationTypeWrite, data: data)
        }
        if callback != nil {
            self.writeOperateCallback = callback
        }
        if let data = data {
            let writeType:CBCharacteristicWriteType = (callback != nil) ? .withResponse:.withoutResponse
            TFYSwiftAsynce.async {
            } _: {
                guard let peripheral = self.peripheral?.peripheral, let characteristic = self.characteristic else {
                    let error = NSError(domain: "设备或特征为空", code: -1, userInfo: nil)
                    callback?(self, data, error)
                    return
                }
                peripheral.writeValue(data, for: characteristic, type: writeType)
            }
        }
    }
    //#warning ====需要一个写入队列
    public func readValueWithCallback(callback:blueToothCharactersticOperateCallback?) {
        if callback != nil {
            self.readOperateCallback = callback
        }
        guard let peripheral = self.peripheral?.peripheral, let characteristic = self.characteristic else {
            let error = NSError(domain: "设备或特征为空", code: -1, userInfo: nil)
            callback?(self, nil, error)
            return
        }
        peripheral.readValue(for: characteristic)
    }

    public func notifyWithValue(value:Bool,callback:blueToothCharactersticOperateCallback?) {
        if callback != nil {
            self.notifyOperateCallback = callback
        }
        if let peripheral = self.peripheral?.peripheral, let characteristic = self.characteristic {
            print("\(String(format: "监听特征上的通知 %@ %d", characteristic.uuid.uuidString,NSNumber(value: value)))")
            peripheral.setNotifyValue(value, for: characteristic)
        } else {
            print("外围设备为空！")
            let error = NSError(domain: "外围设备为空", code: -1, userInfo: nil)
            callback?(self, nil, error)
        }
    }

    /// 处理service中搜索到descriper的结果
    public func dealDiscoverDescriptorWithError(error:Error?) {
        self.characteristic?.descriptors?.forEach({ tempD in
            let tDescroptor:TFYSwiftEasyDescriptor? = searchDescriptoriWithDescriptor(descriptor: tempD)
            if tDescroptor == nil, let peripheral = self.peripheral {
                let character:TFYSwiftEasyDescriptor? = TFYSwiftEasyDescriptor(descriptor: tempD, peripheral: peripheral)
                if let character = character {
                    self.descriptorArray.append(character)
                }
            }
        })
        if self.blueToothFindDescriptorCallback != nil {
            self.blueToothFindDescriptorCallback!(self.descriptorArray,error)
        }
    }

    /// 查找特征中的描述
    public func searchDescriptoriWithDescriptor(descriptor:CBDescriptor) -> TFYSwiftEasyDescriptor? {
        var tempD:TFYSwiftEasyDescriptor?
        self.descriptorArray.forEach { tDescriptor in
            if descriptor.uuid.isEqual(tDescriptor.UUID) {
                tempD = tDescriptor
            }
        }
        return tempD
    }

    /// 查找服务上的特征
    public func discoverDescriptorWithCallback(callback:blueToothFindDescriptorCallback?) {
        if let characteristic = self.characteristic {
            if callback != nil {
                self.blueToothFindDescriptorCallback = callback
            }
            self.peripheral?.peripheral?.discoverDescriptors(for: characteristic)
        } else {
            print("注意：您尝试在无效特征上找到解密器！")
            let error = NSError(domain: "特征无效", code: -1, userInfo: nil)
            callback?([], error)
        }
    }

    public func addDataToArrayWithType(type:OperationType,data:Data?) {
        switch type {
        case .OperationTypeWrite:
            if self.writeDataArray.count >= 5 {
                self.writeDataArray.removeAll()
            }
            if data != nil {
                self.writeDataArray.insert(data!, at: 0)
            }
            break
        case .OperationTypeRead:
            if self.readDataArray.count >= 5 {
                self.readDataArray.removeAll()
            }
            if data != nil {
                self.readDataArray.insert(data!, at: 0)
            }
            break
        case .OperationTypeNotify:
            if self.notifyDataArray.count >= 5 {
                self.notifyDataArray.removeAll()
            }
            if data != nil {
                self.mutableArrayValue(forKey: "notifyDataArray").insert(data!, at: 0)
            }
            break
        }
    }

    deinit {
        self.characteristic = nil
        self.service = nil
        self.peripheral = nil
        self.descriptorArray.removeAll()
        self.readDataArray.removeAll()
        self.writeDataArray.removeAll()
        self.notifyDataArray.removeAll()
        self.readCallbackArray.removeAll()
        self.writeCallbackArray.removeAll()
        self.notifyCallbackArray.removeAll()
    }
}

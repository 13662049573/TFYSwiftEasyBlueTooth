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
    typealias blueToothCharactersticOperateCallback = (_ characteristic:TFYSwiftEasyCharacteristic,_ data:Data?,_ error:Error?) -> Void
    /// 查找到特征上的描述回调
    typealias blueToothFindDescriptorCallback = (_ descriptorArray:[TFYSwiftEasyDescriptor],_ error:Error?) -> Void
    
    private var blueToothFindDescriptorCallback:blueToothFindDescriptorCallback? //查询完descripter后的回调
    private var writeOperateCallback:blueToothCharactersticOperateCallback?
    private var readOperateCallback:blueToothCharactersticOperateCallback?
    private var notifyOperateCallback:blueToothCharactersticOperateCallback?
    private var readCallbackArray:[blueToothCharactersticOperateCallback] = [blueToothCharactersticOperateCallback]()
    private var writeCallbackArray:[blueToothCharactersticOperateCallback] = [blueToothCharactersticOperateCallback]()
    private var notifyCallbackArray:[blueToothCharactersticOperateCallback] = [blueToothCharactersticOperateCallback]()
    
    /// 特征名称
    var name:String? { self.characteristic?.uuid.uuidString }

    /// 特征的唯一标示
    var UUID: CBUUID? { self.characteristic?.uuid }
    
    /// 系统提供的特此
    var characteristic:CBCharacteristic?
    
    /// 特征所属的服务
    var service:TFYSwiftEasyService?
    
    /// 特征所属的设备
    var peripheral:TFYSwiftEasyPeripheral?
    
    /// 特征上所有的特性
    var properties:CBCharacteristicProperties { CBCharacteristicProperties(rawValue: (self.characteristic?.properties)!.rawValue) }

    var propertiesString:String {
        let temProperties:CBCharacteristicProperties = self.properties
        let tempString:NSMutableString = NSMutableString()
        switch temProperties {
           case .broadcast :
            tempString.append("Broadcast ")
            break
        case .writeWithoutResponse:
            tempString.append("WithoutResponse ")
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
            tempString.append("AuthenticatedSignedWrites ")
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
            if tempString.length > 1 {
                tempString.replaceCharacters(in: NSMakeRange(tempString.length-1, 1), with: "")
            }
            break
        }
        return tempString as String
    }
    
    /// 所包含的数据
    var value:Data? {self.characteristic?.value}
    
    ///  是否正在监听数据
    var isNotifying:Bool? { characteristic?.isNotifying }
    
    /// 特征中所有的描述
    var descriptorArray:[TFYSwiftEasyDescriptor] = [TFYSwiftEasyDescriptor]()
    
    /// 接收到的数据都在这个数组里面，记录最后5次的操作
    @objc dynamic var readDataArray:[Data] = [Data]()
    @objc dynamic var writeDataArray:[Data] = [Data]()
    @objc dynamic var notifyDataArray:[Data] = [Data]()
    
    
    /// 初始化方法
    init(character:CBCharacteristic?,peripheral:TFYSwiftEasyPeripheral) {
        super.init()
        
        self.characteristic = character
        self.peripheral = peripheral
    }
    
    /// 处理 easyPeripheral操作完的回到
    func dealOperationCharacterWithType(type:OperationType,error:Error?) {
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
                self.addDataToArrayWithType(type: .OperationTypeNotify, data: self.value)
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
    func writeValueWithData(data:Data?,callback:blueToothCharactersticOperateCallback?) {
        if data != nil {
            self.addDataToArrayWithType(type: .OperationTypeWrite, data: data!)
        }
        if callback != nil {
            self.writeOperateCallback = callback
        }
        if data != nil {
            let writeType:CBCharacteristicWriteType = (callback != nil) ? .withResponse:.withoutResponse
            TFYSwiftAsynce.async {
            } _: {
                self.peripheral?.peripheral?.writeValue(data!, for: self.characteristic!, type: writeType)
            }
        }
    }
    //#warning ====需要一个写入队列
    func readValueWithCallback(callback:blueToothCharactersticOperateCallback?) {
        if callback != nil {
            self.readOperateCallback = callback
        }
        self.peripheral?.peripheral?.readValue(for: self.characteristic!)
    }
    
    func notifyWithValue(value:Bool,callback:blueToothCharactersticOperateCallback?) {
        if callback != nil {
            self.notifyOperateCallback = callback
        }
        if self.peripheral != nil {
            print("\(String(format: "监听特征上的通知 %@ %d", self.characteristic!.uuid.uuidString,NSNumber(value: value)))")
            self.peripheral?.peripheral?.setNotifyValue(value, for: self.characteristic!)
        } else {
            print("外围设备为空！")
        }
    }
    
    /// 处理service中搜索到descriper的结果
    func dealDiscoverDescriptorWithError(error:Error?) {
        self.characteristic?.descriptors?.forEach({ tempD in
            let tDescroptor:TFYSwiftEasyDescriptor? = searchDescriptoriWithDescriptor(descriptor: tempD)
            if tDescroptor == nil {
                let character:TFYSwiftEasyDescriptor? = TFYSwiftEasyDescriptor(descriptor: tempD, peripheral: self.peripheral!)
                if character != nil {
                    self.descriptorArray.append(character!)
                }
            }
        })
        if self.blueToothFindDescriptorCallback != nil {
            self.blueToothFindDescriptorCallback!(self.descriptorArray,error)
        }
    }
    
    /// 查找特征中的描述
    func searchDescriptoriWithDescriptor(descriptor:CBDescriptor) -> TFYSwiftEasyDescriptor? {
        var tempD:TFYSwiftEasyDescriptor?
        self.descriptorArray.forEach { tDescriptor in
            if descriptor.uuid.isEqual(tDescriptor.UUID) {
                tempD = tDescriptor
            }
        }
        return tempD
    }
    
    /// 查找服务上的特征
    func discoverDescriptorWithCallback(callback:blueToothFindDescriptorCallback?) {
        if self.characteristic != nil {
            if callback != nil {
                self.blueToothFindDescriptorCallback = callback
            }
            self.peripheral?.peripheral?.discoverDescriptors(for: self.characteristic!)
        } else {
            print("注意：您尝试在无效特征上找到解密器！")
        }
    }
    
    func addDataToArrayWithType(type:OperationType,data:Data?) {
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
    
    
}


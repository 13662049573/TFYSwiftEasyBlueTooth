//
//  TFYSwiftEasyDescriptor.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import UIKit
import CoreBluetooth

public class TFYSwiftEasyDescriptor: NSObject {

    typealias blueToothDescriptorOperateCallback = (_ descriptor:TFYSwiftEasyDescriptor,_ error:Error?) -> Void
    
    private var readCallback:blueToothDescriptorOperateCallback?
    private var writeCallback:blueToothDescriptorOperateCallback?
    private var readCallbackArray:[Data]?
    
    /// 系统提供的描述
    var descroptor:CBDescriptor?
    
    /// 描述所述的特征
    var characteristic:CBCharacteristic? { self.descroptor?.characteristic }
    
    /// 描述所属的设别
    var peripheral:TFYSwiftEasyPeripheral?
    
    /// 描述的唯一标示
    var UUID: CBUUID? { self.descroptor?.uuid }
    
    /// 当前描述上的值
    var value:Any? { self.descroptor?.value }
    
    /// 描述上读写操作的记录值
    var readDataArray:[Data]?
    var writeDataArray:[Data]?
    
    init(descriptor:CBDescriptor,peripheral:TFYSwiftEasyPeripheral) {
        super.init()
        self.descroptor = descriptor
        self.peripheral = peripheral
    }
    
    /// 在描述上的读写操作
    func writeValueWithData(data:Data?,callback:blueToothDescriptorOperateCallback?) {
        if callback != nil {
            self.writeCallback = callback
        }
        if data != nil {
            if self.writeDataArray == nil {
                self.writeDataArray = []
            }
            self.writeDataArray?.append(data!)
            guard let peripheral = self.peripheral?.peripheral, let descriptor = self.descroptor else {
                let error = NSError(domain: "设备或描述为空", code: -1, userInfo: nil)
                callback?(self, error)
                return
            }
            peripheral.writeValue(data!, for: descriptor)
        }
    }
    /// 在描述上的读写操作
    func readValueWithCallback(callback:blueToothDescriptorOperateCallback?) {
        if callback != nil {
            self.readCallback = callback
        }
        guard let peripheral = self.peripheral?.peripheral, let descriptor = self.descroptor else {
            let error = NSError(domain: "设备或描述为空", code: -1, userInfo: nil)
            callback?(self, error)
            return
        }
        peripheral.readValue(for: descriptor)
    }
    
    /// 处理 easyPeripheral操作完的回到
    func dealOperationDescriptorWithType(type:OperationType, eroor:Error?) {
        switch type {
        case .OperationTypeWrite:
            if self.writeCallback != nil {
                self.writeCallback!(self,eroor)
            }
        case .OperationTypeRead:
            if self.readCallback != nil {
                self.readCallback!(self,eroor)
            }
        default:
            break
        }
    }
    
    deinit {
        self.descroptor = nil
        self.peripheral = nil
        self.readDataArray = nil
        self.writeDataArray = nil
    }
}

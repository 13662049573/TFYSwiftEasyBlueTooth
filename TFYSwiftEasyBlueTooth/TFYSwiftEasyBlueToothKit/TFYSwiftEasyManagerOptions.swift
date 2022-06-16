//
//  TFYSwiftEasyManagerOptions.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import UIKit
import Foundation
import CoreBluetooth

public class TFYSwiftEasyManagerOptions: NSObject {

    /// 蓝牙所有操作所在的线程。如果不传，将会在主线程上操作。
    /// note：如果传入线程，那么返回数据的UI操作需要放到主线程上
    var managerQueue:DispatchQueue?
    
    /// CBCentralManagerOptionShowPowerAlertKey  默认为NO，系统当蓝牙关闭时是否弹出一个警告框
    /// CBCentralManagerOptionRestoreIdentifierKey 系统被杀死，重新恢复centermanager的ID
    var managerDictionary:[String:Any]? = [CBCentralManagerOptionShowPowerAlertKey:true]
    
    /// CBCentralManagerScanOptionAllowDuplicatesKey  默认为NO，过滤功能是否启用，每次寻找都会合并相同的peripheral。如果设备YES的话每次都能接受到来自peripherals的广播包数据。
    /// CBCentralManagerScanOptionSolicitedServiceUUIDsKey  想要扫描的服务的UUID，以一个数组的形式存在。扫描的时候只会扫描到包含这些UUID的设备。
    var scanOptions:[String:Any]? = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
    
    /// 连接设备所需的服务.
    var scanServiceArray:[CBUUID]?
    
    /// 连接设备时所带的条件
    var connectOptions:[String:Any]? = [CBConnectPeripheralOptionNotifyOnConnectionKey:true,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,
                                      CBConnectPeripheralOptionNotifyOnNotificationKey:true]
    
    /// 扫描所需时间。默认为永久
    var scanTimeOut:Int? = NSIntegerMax
    
    /// 连接设备最大时长 默认为5秒
    var connectTimeOut:Int? = 5
    
    /// 断开连接后重新连接
    var autoConnectAfterDisconnect:Bool? = true
    
    init(queue:DispatchQueue?,
         managerDictionary:[String:Any]? = [CBCentralManagerOptionShowPowerAlertKey:true],
         scanOptions:[String:Any]? = [CBCentralManagerScanOptionAllowDuplicatesKey:true],
         scanServiceArray:[CBUUID]? = [CBUUID](),
         connectOptions:[String:Any]?  = [CBConnectPeripheralOptionNotifyOnConnectionKey:true,
                                        CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,
                                        CBConnectPeripheralOptionNotifyOnNotificationKey:true]) {
        super.init()
        
        self.managerQueue = queue
        self.managerDictionary = managerDictionary
        self.scanOptions = scanOptions
        self.scanServiceArray = scanServiceArray
        self.connectOptions = connectOptions
    }
}

//
//  TFYSwiftEasyUtils.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import Foundation
import UIKit
import Accelerate
import CoreBluetooth

extension String {
    /// 将16进制的字符串转换成NSData
    func blueheadecimal() -> Data? {
        var data = Data(capacity: self.count/2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString,radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else {
            return nil
        }
        return data
    }
    
    /// 验证UUID格式
    func isValidUUID() -> Bool {
        return UUID(uuidString: self) != nil
    }
    
    /// 验证蓝牙地址格式
    func isValidBluetoothAddress() -> Bool {
        let pattern = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, range: range) != nil
    }
}

extension Data {
    ///Data转16进制字符串
    func bluehexString() -> String {
        return map { String(format: "%02x", $0) }.joined(separator: "").uppercased()
    }
    
    /// 转换为字节数组
    func toByteArray() -> [UInt8] {
        return Array(self)
    }
    
    /// 从字节数组创建Data
    static func fromByteArray(_ bytes: [UInt8]) -> Data {
        return Data(bytes)
    }
    
    /// 反转字节顺序
    func reversedBytes() -> Data {
        return Data(self.reversed())
    }
    
    /// 获取指定范围的字节
    func subdata(from start: Int, length: Int) -> Data? {
        guard start >= 0 && length > 0 && start + length <= self.count else {
            return nil
        }
        return self.subdata(in: start..<(start + length))
    }
}

extension UIWindow {
    
    static var bluekeyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            // iOS 15+ 使用新的API
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return nil
            }
            return windowScene.windows.first { $0.isKeyWindow }
        } 
    }
}

extension UIImage {
    static func blueimageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect.init(x: 0, y: 0, width: 2, height: 2)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let insets: UIEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        image = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        return image
    }
}

/// 蓝牙工具类
public class TFYBluetoothUtils {
    
    /// 计算RSSI信号强度等级
    /// - Parameter rssi: RSSI值
    /// - Returns: 信号强度等级 (0-4)
    public static func calculateSignalStrength(rssi: NSNumber) -> Int {
        let rssiValue = rssi.intValue
        if rssiValue >= -50 {
            return 4 // 很强
        } else if rssiValue >= -60 {
            return 3 // 强
        } else if rssiValue >= -70 {
            return 2 // 中等
        } else if rssiValue >= -80 {
            return 1 // 弱
        } else {
            return 0 // 很弱
        }
    }
    
    /// 格式化蓝牙地址
    /// - Parameter address: 原始地址字符串
    /// - Returns: 格式化后的地址
    public static func formatBluetoothAddress(_ address: String) -> String {
        let cleaned = address.replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
        
        guard cleaned.count == 12 else { return address }
        
        var formatted = ""
        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 2 == 0 {
                formatted += ":"
            }
            formatted += String(char)
        }
        return formatted
    }

    /// 计算两个设备之间的距离（基于RSSI）
    /// - Parameters:
    ///   - rssi: RSSI值
    ///   - txPower: 发射功率
    /// - Returns: 估算距离（米）
    public static func calculateDistance(rssi: NSNumber, txPower: Double = -69.0) -> Double {
        let rssiValue = rssi.doubleValue
        if rssiValue == 0 {
            return -1.0
        }
        
        let ratio = rssiValue * 1.0 / txPower
        if ratio < 1.0 {
            return pow(ratio, 10.0)
        } else {
            return 0.89976 * pow(ratio, 7.7095) + 0.111
        }
    }
    
    /// 字节数组转十六进制字符串
    /// - Parameter bytes: 字节数组
    /// - Returns: 十六进制字符串
    public static func bytesToHexString(_ bytes: [UInt8]) -> String {
        return bytes.map { String(format: "%02X", $0) }.joined(separator: "")
    }
    
    /// 十六进制字符串转字节数组
    /// - Parameter hexString: 十六进制字符串
    /// - Returns: 字节数组
    public static func hexStringToBytes(_ hexString: String) -> [UInt8]? {
        let cleanHex = hexString.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        guard cleanHex.count % 2 == 0 else { return nil }
        
        var bytes: [UInt8] = []
        for i in stride(from: 0, to: cleanHex.count, by: 2) {
            let startIndex = cleanHex.index(cleanHex.startIndex, offsetBy: i)
            let endIndex = cleanHex.index(startIndex, offsetBy: 2)
            let byteString = String(cleanHex[startIndex..<endIndex])
            
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            bytes.append(byte)
        }
        return bytes
    }
    
    /// 检查蓝牙是否可用
    /// - Returns: 蓝牙是否可用
    public static func isBluetoothAvailable() -> Bool {
        let manager = CBCentralManager()
        return manager.state == .poweredOn
    }
    
    /// 获取蓝牙状态描述
    /// - Returns: 状态描述
    public static func getBluetoothStateDescription() -> String {
        let manager = CBCentralManager()
        switch manager.state {
        case .unknown:
            return "未知状态"
        case .resetting:
            return "重置中"
        case .unsupported:
            return "不支持"
        case .unauthorized:
            return "未授权"
        case .poweredOff:
            return "已关闭"
        case .poweredOn:
            return "已开启"
        @unknown default:
            return "未知状态"
        }
    }
}

/// 蓝牙连接重试管理器
public class TFYBluetoothRetryManager {
    
    private var retryCount: Int = 0
    private let maxRetryCount: Int
    private let retryDelay: TimeInterval
    private var retryTimer: DispatchWorkItem?
    
    public init(maxRetryCount: Int = 3, retryDelay: TimeInterval = 2.0) {
        self.maxRetryCount = maxRetryCount
        self.retryDelay = retryDelay
    }
    
    /// 执行带重试的操作
    /// - Parameters:
    ///   - operation: 要执行的操作
    ///   - onSuccess: 成功回调
    ///   - onFailure: 失败回调
    public func executeWithRetry<T>(
        operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
        onSuccess: @escaping (T) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        retryCount = 0
        executeOperation(operation: operation, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    private func executeOperation<T>(
        operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
        onSuccess: @escaping (T) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        operation { [weak self] result in
            switch result {
            case .success(let value):
                self?.retryCount = 0
                onSuccess(value)
            case .failure(let error):
                self?.handleFailure(
                    error: error,
                    operation: operation,
                    onSuccess: onSuccess,
                    onFailure: onFailure
                )
            }
        }
    }
    
    private func handleFailure<T>(
        error: Error,
        operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
        onSuccess: @escaping (T) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        retryCount += 1
        
        if retryCount <= maxRetryCount {
            print("蓝牙操作失败，第\(retryCount)次重试...")
            retryTimer = TFYSwiftAsynce.asyncDelay(retryDelay) { [weak self] in
                self?.executeOperation(operation: operation, onSuccess: onSuccess, onFailure: onFailure)
            }
        } else {
            print("蓝牙操作失败，已达到最大重试次数")
            retryCount = 0
            onFailure(error)
        }
    }
    
    /// 取消重试
    public func cancelRetry() {
        retryTimer?.cancel()
        retryTimer = nil
        retryCount = 0
    }
    
    deinit {
        cancelRetry()
    }
}

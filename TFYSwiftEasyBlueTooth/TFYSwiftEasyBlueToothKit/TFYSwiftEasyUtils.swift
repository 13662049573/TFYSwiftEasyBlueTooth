//
//  TFYSwiftEasyUtils.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import Foundation
import UIKit
import Accelerate

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
}

extension Data {
    ///Data转16进制字符串
    func bluehexString() -> String {
        return map { String(format: "%02x", $0) }.joined(separator: "").uppercased()
    }
}

extension UIWindow {
    
    static var bluekeyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            if let window = UIApplication.shared.delegate?.window as? UIWindow {
                return window
            } else {
                for window in UIApplication.shared.windows where window.windowLevel == .normal && !window.isHidden {
                    return window
                }
                return UIApplication.shared.windows.first
            }
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

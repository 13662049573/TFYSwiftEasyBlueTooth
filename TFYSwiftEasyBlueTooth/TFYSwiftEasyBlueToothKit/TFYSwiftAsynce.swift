//
//  TFYSwiftAsynce.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/13.
//

import Foundation

public typealias TFYSwiftBlock = () -> Void

public struct TFYSwiftAsynce {
    /// 异步处理数据
    public static func async(_ block: @escaping TFYSwiftBlock) {
        _async(block)
    }
    
    /// 异步 主线程 处理数据
    public static func async(_ block: @escaping TFYSwiftBlock, _ mainblock: @escaping TFYSwiftBlock) {
        _async(block, mainblock)
    }
    
    /// 异步延迟
    @discardableResult
    public static func asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock) -> DispatchWorkItem {
        return _asyncDelay(seconds, block)
    }
    
    /// 主线程延迟
    @discardableResult
    public static func asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock, _ mainblock: @escaping TFYSwiftBlock) -> DispatchWorkItem {
        return _asyncDelay(seconds, block, mainblock)
    }
    
    /// 取消延迟任务
    public static func cancelDelay(_ workItem: DispatchWorkItem) {
        workItem.cancel()
    }
    
    /// 在主线程执行
    public static func mainAsync(_ block: @escaping TFYSwiftBlock) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    /// 在后台线程执行
    public static func backgroundAsync(_ block: @escaping TFYSwiftBlock) {
        DispatchQueue.global(qos: .userInitiated).async(execute: block)
    }
}

extension TFYSwiftAsynce {
    
    private static func _async(_ block: @escaping TFYSwiftBlock, _ mainblock: TFYSwiftBlock? = nil) {
        let item = DispatchWorkItem {
            autoreleasepool {
                block()
            }
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: item)
        if let main = mainblock {
            item.notify(queue: DispatchQueue.main) {
                autoreleasepool {
                    main()
                }
            }
        }
    }
    
    private static func _asyncDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock, _ mainblock: TFYSwiftBlock? = nil) -> DispatchWorkItem {
        let item = DispatchWorkItem {
            autoreleasepool {
                block()
            }
        }
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        if let main = mainblock {
            item.notify(queue: DispatchQueue.main) {
                autoreleasepool {
                    main()
                }
            }
        }
        return item
    }
}

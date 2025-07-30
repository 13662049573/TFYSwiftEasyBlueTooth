//
//  TFYSwiftDetailHeaderView.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/16.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit
import CoreBluetooth

class TFYSwiftDetailHeaderView: UIView {
    private let width_w:CGFloat = UIScreen.main.bounds.width
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private lazy var uuidLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private var data:TFYSwiftEasyPeripheral?
    private var kvoToken: NSKeyValueObservation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        addSubview(uuidLabel)
        addSubview(stateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 10, y: 10, width: width_w-20, height: 20)
        uuidLabel.frame = CGRect(x: 10, y: 35, width: width_w-20, height: 20)
        stateLabel.frame = CGRect(x: 10, y: 65, width: width_w-20, height: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var peripheral:TFYSwiftEasyPeripheral? {
        didSet {
            let data = peripheral
            if let data = data {
                self.data = data
                
                self.nameLabel.text = data.name
                self.uuidLabel.text = "UUID:\(data.identifier.uuidString)"
                updateConnectionState(data.state)
                
                // 监听连接状态变化
                kvoToken = data.peripheral?.observe(\.state, options: .new) { [weak self] per, change in
                    DispatchQueue.main.async {
                        self?.updateConnectionState(per.state)
                    }
                }
            }
        }
    }
    
    private func updateConnectionState(_ state: CBPeripheralState) {
        switch state {
        case .connected:
            self.stateLabel.textColor = .green
            self.stateLabel.text = "已连接"
        case .disconnected:
            self.stateLabel.textColor = .red
            self.stateLabel.text = "已断开连接"
        case .connecting:
            self.stateLabel.textColor = .orange
            self.stateLabel.text = "连接中..."
        case .disconnecting:
            self.stateLabel.textColor = .orange
            self.stateLabel.text = "断开中..."
        @unknown default:
            self.stateLabel.textColor = .gray
            self.stateLabel.text = "未知状态"
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }
}

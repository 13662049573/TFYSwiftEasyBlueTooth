//
//  TFYSwiftDetailHeaderView.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/16.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

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
        
//        if data?.peripheral != nil {
//            kvoToken = data?.peripheral?.observe(\.state, options: .new, changeHandler: { per, change in
//                if per.state == .disconnected {
//                    TFYSwiftDetailHeaderView().stateLabel.textColor = .red
//                    TFYSwiftDetailHeaderView().stateLabel.text = "设备失去连接..."
//                } else {
//                    TFYSwiftDetailHeaderView().stateLabel.textColor = .black
//                    TFYSwiftDetailHeaderView().stateLabel.text = "设备已连接"
//                }
//            })
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var peripheral:TFYSwiftEasyPeripheral? {
        didSet {
            let data = peripheral
            if data != nil {
                self.data = data
                
                self.nameLabel.text = data?.name
                self.uuidLabel.text = "UUID:\(data?.identifier.uuidString ?? "")"
                if data?.state == .connected {
                    self.stateLabel.text = "已连接"
                } else if data?.state == .disconnected {
                    self.stateLabel.text = "已断开连接"
                }
            }
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }

}

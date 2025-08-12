//
//  TFYSwiftDetailHeaderFooterView.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftDetailHeaderFooterView: UIView {

    private let width_w:CGFloat = UIScreen.main.bounds.width
    typealias callback = (_ isShow:Int) -> Void
    var callback:callback?
    
    private lazy var serviceNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var showButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitle("展开", for: .normal)
        btn.setTitle("隐藏", for: .selected)
        btn.isSelected = false
        btn.addTarget(self, action: #selector(showButtonClick), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(serviceNameLabel)
        addSubview(showButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        serviceNameLabel.frame = CGRect(x: 10, y: 10, width: width_w-20, height: 30)
        showButton.frame = CGRect(x: width_w-60, y: 10, width: 50, height: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var serviceName:String? {
        didSet {
            let name = serviceName
            if name != nil {
                self.serviceNameLabel.text = name!
            }
        }
    }
    
    var sectionState:Int = 0 {
        didSet {
            let state = sectionState
            self.showButton.isHidden = state == -1 ? true:false
            
        }
    }
    
    @objc func showButtonClick(btn:UIButton) {
        btn.isSelected = !btn.isSelected
        var showIndex:Int = 0
        if btn.isSelected {
            showIndex = 1
        } else {
            showIndex = 0
        }
        if self.callback != nil {
            self.callback!(showIndex)
        }
    }

}

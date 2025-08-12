//
//  TFYSwiftDetailOneTableViewCell.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftDetailOneTableViewCell: UITableViewCell {
    private let width_w:CGFloat = UIScreen.main.bounds.width
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .gray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 10, y: 10, width: width_w-20, height: 20)
        subTitleLabel.frame = CGRect(x: 10, y: 30, width: width_w-20, height: 20)
    }
   
    var data:TFYSwiftEasyCharacteristic? {
        didSet {
            let character = data
            if character != nil {
                self.titleLabel.text = character?.name
                self.subTitleLabel.text = "属性:\(character?.propertiesString ?? "")"
            }
        }
    }
    
    var titleString:Any? {
        didSet {
            let title = titleString
            if title is String {
                self.titleLabel.text = title as? String
            }
        }
    }
    
    var subTitleString:Any?  {
        didSet {
            let sub = subTitleString
            if sub != nil {
                if sub is [Any] {
                    var allString:String = ""
                    let tempArray:[Any] = (sub as! [Any])
                    tempArray.forEach { tempS in
                        allString = (allString as NSString).appending(" \(tempS)")
                    }
                    self.subTitleLabel.text = allString
                } else {
                    self.subTitleLabel.text = "\(sub ?? "")"
                }
            }
        }
    }

}

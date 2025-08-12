//
//  TFYSwiftDetailOperationCell.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/16.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftDetailOperationCell: UITableViewCell {

    private let width_w:CGFloat = UIScreen.main.bounds.width
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 10, y: 10, width: width_w-20, height: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isOperation:Bool = false {
        didSet {
            let open = isOperation
            self.titleLabel.textColor = open ? .blue : .darkGray
        }
    }
    
    var title:String = "" {
        didSet {
            let ti = title
            self.titleLabel.text = ti
        }
    }
    
    
}

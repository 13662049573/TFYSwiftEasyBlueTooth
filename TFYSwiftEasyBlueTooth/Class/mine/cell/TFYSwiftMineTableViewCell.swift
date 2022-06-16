//
//  TFYSwiftMineTableViewCell.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/16.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit

class TFYSwiftMineTableViewCell: UITableViewCell {

    private lazy var nameLabel: UILabel = {
         let label = UILabel()
         label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
         label.adjustsFontSizeToFitWidth = true
         label.numberOfLines = 2
         label.textColor = .black
         return label
     }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width:CGFloat = UIScreen.main.bounds.width
        nameLabel.frame = CGRect(x: 20, y: 0, width: width-40, height: 80)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title:String = "" {
        didSet {
            let name = title
            self.nameLabel.text = name
        }
    }
    
}

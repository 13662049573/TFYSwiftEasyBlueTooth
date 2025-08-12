//
//  TFYViewTableViewCell.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//

import UIKit

class TFYViewTableViewCell: UITableViewCell {
    
   private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    private lazy var rssiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .blue
        label.backgroundColor = .gray
        label.layer.cornerRadius = 8
        label.numberOfLines = 0
        label.textAlignment = .center
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var servicesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .orange
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .gray
        
        contentView.addSubview(rssiLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(stateLabel)
        contentView.addSubview(servicesLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width:Int = Int(UIScreen.main.bounds.width)
        
        rssiLabel.frame = CGRect(x: 20, y: 10, width: 80, height: 60)
        nameLabel.frame = CGRect(x: 110, y: 5, width: width-110-80, height: 40)
        servicesLabel.frame = CGRect(x: 110, y: 40, width: width-110-80, height: 20)
        stateLabel.frame = CGRect(x: width - 80, y: 20, width: 60, height: 40)
    }
    
    var data:TFYSwiftEasyPeripheral? {
        didSet {
            let data = data
            
            if data != nil {
                nameLabel.text = data!.name
                rssiLabel.text = "\(String(format: "RSSI\n%ld", data!.RSSI!.intValue))"
        
                servicesLabel.text = "\(data!.advertisementData.values.count) 个服务"
                
                if data?.state == .connected {
                    stateLabel.text = "已连接"
                } else {
                    stateLabel.text = "未连接"
                }
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

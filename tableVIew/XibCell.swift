//
//  XibCell.swift
//  tableVIew
//
//  Created by wanwu on 17/2/7.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class XibCell: UITableViewCell, CustomTableViewCellProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func bindAdapterModel(model: CustomTableViewCellItem) {
        self.titleLabel.text = model.text
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

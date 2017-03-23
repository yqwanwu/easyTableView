//
//  XibCell.swift
//  tableVIew
//
//  Created by wanwu on 17/2/7.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class XibCell: CustomTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override var model: CustomTableViewCellItem? {
        didSet {
            if let model = model {
                self.titleLabel.text = model.text
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

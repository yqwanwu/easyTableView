//
//  StoryboardCell.swift
//  tableVIew
//
//  Created by wanwu on 17/2/7.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class StoryboardCell: CustomTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override var model: Any? {
        didSet {
            if let model = model as? TestCellModel {
                self.titleLabel.text = model.titleText
            }
        }
    }
    
}

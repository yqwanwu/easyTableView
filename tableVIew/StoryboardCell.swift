//
//  StoryboardCell.swift
//  tableVIew
//
//  Created by wanwu on 17/2/7.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class StoryboardCell: UITableViewCell, CustomTableViewCellProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func bindOriginalModel(model: Any) {
        if let model = model as? TestCellModel {
            self.titleLabel.text = model.titleText
        }
    }
    
}

//
//  self.swift
//  caizhu
//
//  Created by wanwu on 16/8/26.
//  Copyright © 2016年 wanwu. All rights reserved.
//

import UIKit

class BadgeView: UILabel {
    
    var badgeValue: String? {
        willSet {
            if newValue != nil {
                self.layer.cornerRadius = self.frame.height / 2
                self.text = newValue
                
                if let num = Int(newValue!) {
                    if num >= 100 {
                        self.text = "99+"
                    }
                }
                
                let str = self.text! as NSString
                
                let size = CGSize(width: 100, height: frame.height)
                //计算文字长度
                let rec = str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)], context: nil)
                self.frame.size.width = rec.width < frame.height ? str.length < 2 ? frame.height : rec.width + 6 : rec.width + 10
                self.frame.size.height = 16
                self.layer.cornerRadius = 8
                
            } else {
                self.text = nil
                self.frame = CGRect.zero
            }
        }
    }
    
    class func create() -> BadgeView {
        let badgeView = BadgeView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        badgeView.backgroundColor = UIColor.red
        badgeView.textColor = UIColor.white
        badgeView.layer.masksToBounds = true
        badgeView.font = UIFont.systemFont(ofSize: 12)
        badgeView.textAlignment = .center
        badgeView.frame.size.width = 0
        return badgeView
    }

}

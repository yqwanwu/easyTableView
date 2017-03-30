//
//  CommonProxy.swift
//  reuseTest
//
//  Created by wanwu on 17/3/29.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class CommonProxy: NSObject {
    weak var delegate: AnyObject?
    weak var commonDelegate: AnyObject?
    ///如果是false。当delegate有方法时，不执行commonDelegate对应的方法，如果为true，则直接执行commonDelegate中的方法，这样可以适配一些commonDelegate中的特殊处理
    var shouldInvokeCommonMethod = false
    override func responds(to aSelector: Selector!) -> Bool {
        return delegate?.responds(to: aSelector) ?? false || commonDelegate?.responds(to: aSelector) == true
    }
    
    //路由 把其他类的代理设为自己，自己不实现具体方法
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if shouldInvokeCommonMethod, commonDelegate?.responds(to: aSelector) == true {                return commonDelegate
        }
        
        if delegate?.responds(to: aSelector) == true {
            return delegate
        } else if commonDelegate?.responds(to: aSelector) == true {
            return commonDelegate
        }
        
        return super.forwardingTarget(for: aSelector)
    }
    
    /// delegate 真实 的代理，  commonDelegate: 通用代理，这里面实现全部通用逻辑，如果delegate实现了该方法
    init(delegate: AnyObject?, commonDelegate: AnyObject?) {
        super.init()
        self.delegate = delegate
        self.commonDelegate = commonDelegate
    }
}


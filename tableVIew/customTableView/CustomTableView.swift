//
//  CustomTableView.swift
//  coreTextTest
//
//  Created by wanwu on 16/7/28.
//  Copyright © 2016年 wanwu. All rights reserved.
//

import UIKit

class CustomTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    ///必须卸载这防止提前被释放
    fileprivate weak var originalDataSouce: UITableViewDataSource?
    fileprivate weak var originalDelegate: UITableViewDelegate?
    private var dataSouceProxy: _CustomTableViewDataSource?
    private var delegateProxy: _CustomTableViewDelegate?
    private var destroyed = false
    
    var dataArray: [[CustomTableViewCellItem]] = [[CustomTableViewCellItem]]() {
        willSet {
            var identifier = ""
            
            var set: Set = Set<String>()
            for outData in newValue {
                for data in outData {
                    if data.isFromStoryBord { continue }
                    set.insert(NSStringFromClass(data.cellClass))
                }
            }
            
            for s in set {
                identifier = (s as NSString).pathExtension
                self.register(NSClassFromString(s), forCellReuseIdentifier: identifier)
                
                if Bundle.main.path(forResource: identifier, ofType: "nib") != nil {
                    let nib = UINib(nibName: identifier, bundle: Bundle.main)
                    self.register(nib, forCellReuseIdentifier: identifier)
                }
            }
        }
    }
    
    override var dataSource: UITableViewDataSource? {
        didSet {
            if destroyed {
                return
            }
            originalDataSouce = dataSource
            dataSouceProxy = dataSource == nil ? nil : _CustomTableViewDataSource(delegate: dataSource, commonDelegate: self)
            dataSouceProxy?.obj = self
            super.dataSource = dataSouceProxy
        }
    }
    
    override var delegate: UITableViewDelegate? {
        didSet {
            if destroyed {
                return
            }
            originalDelegate = delegate
            delegateProxy = delegate == nil ? nil : _CustomTableViewDelegate(delegate: delegate, commonDelegate: self)
            super.delegate = delegateProxy
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.dataSource = self
        self.delegate = self
        if self.tableFooterView == nil {
            self.tableFooterView = UIView()
        }
        
        self.sectionHeaderHeight = 0.1
        self.sectionFooterHeight = 0.1
    }
    
    deinit {
        destroyed = true
        debugPrint("tableView销毁")
    }
    
    private class _CustomTableViewDataSource: CommonProxy, UITableViewDataSource {
        weak var obj: CustomTableView!
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return obj.tableView(tableView, numberOfRowsInSection: section)
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return obj.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    private class _CustomTableViewDelegate: CommonProxy, UITableViewDelegate {
        
    }
}

extension CustomTableView {
    ///datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let od = originalDataSouce, !od.isEqual(self) {
            let number = od.tableView(tableView, numberOfRowsInSection: section)
            if number > 0 {
                return number
            }
        }
        
        return dataArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let od = originalDataSouce, !od.isEqual(self) {
            let cell = od.tableView(tableView, cellForRowAt: indexPath)
            if cell != CustomTableViewCell.placeholderCell {
                if let cc = cell as? CustomTableViewCell {
                    cc.tableView = tableView
                }
                return cell
            }
        }
        
        let data = dataArray[indexPath.section][indexPath.row]
        let identifier = (NSStringFromClass(data.cellClass) as NSString).pathExtension
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? CustomTableViewCell {
            cell.tableView = tableView
            cell.indexPath = indexPath as NSIndexPath
            cell.model = data
            cell.accessoryType = data.accessoryType
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let od = originalDataSouce, !od.isEqual(self) {
            if let number = od.numberOfSections?(in: tableView) {
                return number
            }
        }
        return dataArray.count
    }
    
    ///delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let od = originalDelegate, !od.isEqual(self) {
            if let h = od.tableView?(tableView, heightForRowAt: indexPath) {
                return h
            }
        }
        
        if dataArray.isEmpty {
            return 44.0
        }
        
        let model: CustomTableViewCellItem = dataArray[indexPath.section][indexPath.row]
        return model.heightForRow
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if let od = originalDelegate, !od.isEqual(self), let h = od.tableView?(tableView, heightForFooterInSection: section) {
            return h
        }
        
        return max(tableView.sectionFooterHeight, 0.1)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let od = originalDelegate, !od.isEqual(self), let h = od.tableView?(tableView, heightForHeaderInSection: section) {
            return h
        }
        
        return max(tableView.sectionHeaderHeight, 0.1)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let od = originalDelegate, !od.isEqual(self) {
            if let _ = od.tableView?(tableView, didSelectRowAt: indexPath) {
                return
            }
        }
        
        if dataArray.isEmpty {
            return
        }
        
        let model: CustomTableViewCellItem = dataArray[indexPath.section][indexPath.row]
        model.cellAction(indexPath)
    }
}




class CustomTableViewCellItem: NSObject {
    typealias cellSelectedAction = (_ idx: IndexPath) -> Void
    
    var imageUrl: String?
    var text: String?
    var detailText: String?
    var cellClass: AnyClass!
    var heightForRow: CGFloat = UITableViewAutomaticDimension
    var accessoryType: UITableViewCellAccessoryType = .none
    var cellAction: cellSelectedAction = {_ in }
    ///默认是从xib加载，storybord中设计的cell，就只需要注册class，不用注册nib。
    var isFromStoryBord = false
    
    var customValue: [String:Any]?
    
    func setupCellAction(_ cellAction: @escaping cellSelectedAction) {
        self.cellAction = cellAction
    }
    
    override init() {
        super.init()
    }
    
    @discardableResult
    func build(customValue _customValue: [String:Any]) -> Self {
        self.customValue = _customValue
        return self
    }
    
    @discardableResult
    func build(isFromStoryBord _isFromStoryBord: Bool) -> Self {
        self.isFromStoryBord = _isFromStoryBord
        return self
    }
    
    @discardableResult
    func build(imageUrl _imageUrl: String?) -> Self {
        self.imageUrl = _imageUrl
        return self
    }
    
    @discardableResult
    func build(text _text: String?) -> Self {
        self.text = _text
        return self
    }
    
    @discardableResult
    func build(detailText _detailText: String?) -> Self {
        self.detailText = _detailText
        return self
    }
    
    @discardableResult
    func build(accessoryType _accessoryType: UITableViewCellAccessoryType) -> Self {
        self.accessoryType = _accessoryType
        return self
    }
    
    @discardableResult
    func build(cellClass _cellClass: AnyClass) -> Self {
        self.cellClass = _cellClass
        return self
    }
    
    @discardableResult
    func build(heightForRow height: CGFloat) -> Self {
        self.heightForRow = height
        return self
    }
}

class CustomTableViewCell: UITableViewCell {
    weak var vc: UIViewController?
    
    var model: CustomTableViewCellItem?
    weak var tableView: UITableView?
    var indexPath: NSIndexPath?
    
    static let placeholderCell = CustomTableViewCell()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}


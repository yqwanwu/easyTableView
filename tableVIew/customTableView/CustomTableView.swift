//
//  CustomTableView.swift
//  coreTextTest
//
//  Created by wanwu on 16/7/28.
//  Copyright © 2016年 wanwu. All rights reserved.
//

import UIKit

class CustomTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    ///这防止提前被释放
    fileprivate weak var originalDataSouce: UITableViewDataSource?
    fileprivate weak var originalDelegate: UITableViewDelegate?
    private var dataSouceProxy: _CustomTableViewDataSource?
    private var delegateProxy: _CustomTableViewDelegate?
    //防止已经销毁还在使用weak属性
    private var destroyed = false
    
    //占位 如果返回这个cell。tableview自动处理cell
    static let PLACEHODEL_CELL = UITableViewCell()
    
    var dataArray: [[CustomTableViewCellItem]] = [[CustomTableViewCellItem]]() {
        willSet {
            var identifier = ""
            
            var set: Set = Set<String>()
            var customIdentifierDic = [String: CustomTableViewCellItem]()
            for outData in newValue {
                for data in outData {
                    if let id = data.cellIdentify {
                        customIdentifierDic[id] = data
                        if self.dequeueReusableCell(withIdentifier: id) == nil {
                            self.register(NSClassFromString(id), forCellReuseIdentifier: identifier)
                        }
                    } else {
                        set.insert(NSStringFromClass(data.cellClass))
                    }
                }
            }
            
            for s in set {
                identifier = (s as NSString).pathExtension
                if self.dequeueReusableCell(withIdentifier: identifier) == nil {
                    if Bundle.main.path(forResource: identifier, ofType: "nib") != nil {
                        let nib = UINib(nibName: identifier, bundle: Bundle.main)
                        self.register(nib, forCellReuseIdentifier: identifier)
                    } else {
                        self.register(NSClassFromString(s), forCellReuseIdentifier: identifier)
                    }
                }
            }
            
            for (k, v) in customIdentifierDic {
                if self.dequeueReusableCell(withIdentifier: k) == nil {
                    if Bundle.main.path(forResource: k, ofType: "nib") != nil {
                        let nib = UINib(nibName: k, bundle: Bundle.main)
                        self.register(nib, forCellReuseIdentifier: k)
                    } else {
                        self.register(v.cellClass, forCellReuseIdentifier: k)
                    }
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
        
        self.estimatedRowHeight = 50
        self.rowHeight = UITableViewAutomaticDimension
    }
    
    ///获取 原始数据模型
    /// - Parameter type: 数据类型，如 Int.self
    func getOriginalModle<T>(indexPath: IndexPath, type: T.Type) -> T? {
        if indexPath.section < dataArray.count && indexPath.row < dataArray[indexPath.section].count {
            if let model = dataArray[indexPath.section][indexPath.row].originalModel as? T {
                return model
            }
        }
        return nil
    }
    
    ///获取 UI模型
    func getAdapterModle(indexPath: IndexPath) -> CustomTableViewCellItem? {
        if indexPath.section < dataArray.count && indexPath.row < dataArray[indexPath.section].count {
            return dataArray[indexPath.section][indexPath.row]
        }
        return nil
    }
    
    ///创建一个默认的cell，
    func createDefaultCell(indexPath: IndexPath) -> UITableViewCell {
        let data = dataArray[indexPath.section][indexPath.row]
        let identifier = data.cellIdentify ?? (NSStringFromClass(data.cellClass) as NSString).pathExtension
        let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? CustomTableViewCellProtocol {
            cell.bindAdapterModel(model: data)
            cell.bindOriginalModel(model: data.originalModel)
        }
        cell.accessoryType = data.accessoryType
        
        return cell
    }
    
    deinit {
        destroyed = true
        debugPrint("tableView销毁")
    }
    
    //代理类
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
            if cell != CustomTableView.PLACEHODEL_CELL {
                return cell
            }
        }
        return createDefaultCell(indexPath: indexPath)
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



///数据源
class CustomTableViewCellItem: NSObject {
    typealias cellSelectedAction = (_ idx: IndexPath) -> Void
    
    //原始数据，对应cell的model， CustomTableViewCellItem 对应cell 的 adapterModel
    var originalModel: Any = NSObject()
    
    //一些方便后面使用的属性
    var imageUrl: String?
    var text: String?
    var detailText: String?
    
    var cellClass: AnyClass!
    ///如果设置了 cellClass 没有设置 cellIdentify， 则 identify 默认和cellClass同名
    var cellIdentify: String?
    
    var heightForRow: CGFloat = UITableViewAutomaticDimension
    var accessoryType: UITableViewCellAccessoryType = .none
    var cellAction: cellSelectedAction = {_ in }
    
    func setupCellAction(_ cellAction: @escaping cellSelectedAction) {
        self.cellAction = cellAction
    }
    
    override init() {
        super.init()
    }
    
    @discardableResult
    func build(originalModel _originalModel: Any) -> Self {
        self.originalModel = _originalModel
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
    
    ///如果设置了 cellClass 没有设置 cellIdentify， 则 identify 默认和cellClass同名
    @discardableResult
    func build(cellIdentify _cellIdentify: String?) -> Self {
        self.cellIdentify = _cellIdentify
        return self
    }
    
    @discardableResult
    func build(heightForRow height: CGFloat) -> Self {
        self.heightForRow = height
        return self
    }
}


/// cell 数据绑定协议
protocol CustomTableViewCellProtocol {
    ///绑定原始数据
    func bindOriginalModel(model: Any)
    
    ///绑定包装数据
    func bindAdapterModel(model: CustomTableViewCellItem)
}

///协议的默认实现
extension CustomTableViewCellProtocol {
    func bindOriginalModel(model: Any) {  }
    
    func bindAdapterModel(model: CustomTableViewCellItem) {  }
}


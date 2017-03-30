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
//        didSet {
//            originalDataSouce = dataSource
//            super.dataSource = self
//        }
        set {
            if newValue != nil {
                dataSouceProxy = _CustomTableViewDataSource(delegate: newValue, commonDelegate: self)
                dataSouceProxy?.obj = self
            }
            
            super.dataSource = dataSouceProxy
            originalDataSouce = newValue
        }
        
        get {
            return super.dataSource
        }
    }
    
    override var delegate: UITableViewDelegate? {
        
//        didSet {
//            originalDelegate = delegate
//            super.delegate = self
//        }
        set {
            if newValue != nil {
                delegateProxy = _CustomTableViewDelegate(delegate: newValue, commonDelegate: self)
            }
            super.delegate = delegateProxy
            originalDelegate = newValue
        }
        
        get {
            return super.delegate
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
        self.tableFooterView = UIView()
        self.sectionHeaderHeight = 0.1
        self.sectionFooterHeight = 0.1
    }
    
    deinit {
        print("tableView销毁")
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CustomTableViewCell {
            cell.tableView = tableView
            cell.indexPath = indexPath as NSIndexPath
            cell.model = data
            cell.accessoryType = data.accessoryType
            return cell
        }
        
        return CustomTableViewCell.placeholderCell
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
    
    func setupCellAction(_ cellAction: @escaping cellSelectedAction) {
        self.cellAction = cellAction
    }
    
    
    override init() {
        super.init()
    }
    
    init(builder: Builder) {
        super.init()
        self.imageUrl = builder.imageUrl
        self.text = builder.text
        self.detailText = builder.detailText
        self.accessoryType = builder.accessoryType
        self.cellClass = builder.cellClass ?? CustomTableViewCellItem.self
        self.heightForRow = builder.heightForRow
        self.isFromStoryBord = builder.isFromStoryBord
    }
    
    class Builder: CustomTableViewCellItem {
        
        func build(isFromStoryBord _isFromStoryBord: Bool) -> Builder {
            self.isFromStoryBord = _isFromStoryBord
            return self
        }
        
        func build(imageUrl _imageUrl: String?) -> Builder {
            self.imageUrl = _imageUrl
            return self
        }
        
        func build(text _text: String?) -> Builder {
            self.text = _text
            return self
        }
        
        func build(detailText _detailText: String?) -> Builder {
            self.detailText = _detailText
            return self
        }
        
        func build(accessoryType _accessoryType: UITableViewCellAccessoryType) -> Builder {
            self.accessoryType = _accessoryType
            return self
        }
        
        func build(cellClass _cellClass: AnyClass) -> Builder {
            self.cellClass = _cellClass
            return self
        }
        
        func build(heightForRow height: CGFloat) -> Builder {
            self.heightForRow = height
            return self
        }
        
        func build() -> CustomTableViewCellItem {
            return CustomTableViewCellItem(builder: self)
        }
    }
}

class CustomTableViewCell: UITableViewCell {
    var badgeView: BadgeView = BadgeView.create()
    weak var viewController: UIViewController?
    
    var model: CustomTableViewCellItem?
    weak var tableView: UITableView?
    var indexPath: NSIndexPath?
    
    static let placeholderCell = CustomTableViewCell()
    
    var badgeValue: String? {
        didSet {
            badgeView.badgeValue = badgeValue
            badgeView.center = CGPoint(x: contentView.frame.width - badgeView.frame.width - 40, y: contentView.frame.height / 2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        badgeView.textColor = UIColor.white
        badgeView.layer.masksToBounds = true
        badgeView.font = UIFont.systemFont(ofSize: 12)
        badgeView.textAlignment = .center
        self.selectionStyle = .none
    }
    
    private var addedBadgeValue = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        badgeView.center = CGPoint(x: contentView.frame.width - badgeView.frame.width - 30, y: contentView.frame.height / 2)
        badgeView.backgroundColor = UIColor.red
        
        if !addedBadgeValue {
            addedBadgeValue = true
            contentView.addSubview(badgeView)
        }
    }
}

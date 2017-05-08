//
//  NextViewController.swift
//  tableVIew
//
//  Created by wanwu on 17/2/7.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class NextViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: CustomTableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        //如果设置代理为自己 需要自己设定 rowHeight
        tableView.delegate = self

        let xibModel = CustomTableViewCellItem().build(text: "xib....").build(cellClass: XibCell.self).build(heightForRow: 100)
        xibModel.cellAction = { (idx) in
            print(idx.row)
        }

        tableView.dataArray = [[xibModel, xibModel, xibModel]]
    }

}


extension NextViewController {
    //MARK: delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //返回 -1，则自动计算
        return -1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*若返回 CustomTableViewCell.placeholderCell(), 自动生成 cell*/
//        return CustomTableViewCell.placeholderCell()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "XibCell", for: indexPath) as! XibCell
        cell.model = self.tableView.dataArray[indexPath.section][indexPath.row]
        cell.contentView.backgroundColor = UIColor(red: CGFloat(arc4random() % 100) / CGFloat(100.0), green: CGFloat(arc4random() % 100) / CGFloat(100.0), blue: CGFloat(arc4random() % 100) / CGFloat(100.0), alpha: 1)
        return cell
    }
}

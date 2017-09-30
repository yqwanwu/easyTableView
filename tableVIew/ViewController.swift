//
//  ViewController.swift
//  tableVIew
//
//  Created by wanwu on 17/2/7.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: CustomTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionHeaderHeight = 20
        
        //MARK: 创建数据源
        //类型1：storybord中的cell
        let sbModel = TestCellModel()
        sbModel.titleText = "storyboard !!!"
//        let cellItem = CustomTableViewCellItem(cellClass: StoryboardCell.self, originalModel: sbModel)
//            .build(heightForRow: 150)
//        cellItem.cellAction = { indexPath in
//            print(indexPath.row)
//        }
        
        //类型2：xib中的cell
        
        let xibModel = CustomTableViewCellItem(cellClass: XibCell.self, originalModel: NSObject()).build(text: "xib....")
        xibModel.cellAction = { indexPath in
            print(indexPath.row)
        }
        
        //类型3：cell的名字和identitify不一致
        //随便指定一个class。懒得写了, 如果没在storybord中注册也会自动注册
        let thirdModel = CustomTableViewCellItem(cellClass: UITableViewCell.self, originalModel: NSObject()).build(cellIdentify: "cell").build(heightForRow: 100)
        
        //MARK: 添加数据
//        tableView.dataArray = [[cellItem], [thirdModel]]
//        tableView.dataArray.append([cellItem, xibModel, cellItem])
        
        tableView.insertNewSectionCells(models: [sbModel], cellClass: StoryboardCell.self)
            .build(heightForRow: 150)
            .buildCellAction { (idx, _) in
                print(idx)
        }
        tableView.insertNewSectionCells(models: [NSObject()], cellClass: XibCell.self)
            .build(text: "xib....")
            .buildCellAction { (idx, model) in
                print(model)
        }
        tableView.insertNewSectionCells(models: [sbModel], cellClass: StoryboardCell.self).build(heightForRow: 90)
        tableView.insertCells(models: [sbModel, sbModel], cellClass: StoryboardCell.self).build(heightForRow: 70)
        
        
        //MARK: 配置tableVIew
        tableView.sectionHeaderHeight = 50
        
//        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("aaaaaaa")
    }
    
    deinit {
        print("vc 销毁")
    }

}


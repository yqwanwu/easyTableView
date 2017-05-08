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
    
    @IBAction func ac_done(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: 创建数据源
        //如果是 storybord 中的cell 必须指定 cell 的 identifier 为 cellClss的同名 如： StoryboardCell
        let sbModel = TestCellModel(builder: TestCellModel.Builder()
            .build(cellClass: StoryboardCell.self)
            .build(isFromStoryBord: true)
            .build(heightForRow: 150))
        
        sbModel.titleText = "storyboard !!!"
        sbModel.cellAction = { indexPath in
            print(indexPath.row)
        }
        
        let xibModel = CustomTableViewCellItem.Builder().build(text: "xib....").build(cellClass: XibCell.self).build()
        xibModel.cellAction = { indexPath in
            print(indexPath.row)
        }
        
        //MARK: 添加数据
        tableView.dataArray = [[sbModel, xibModel], [sbModel, xibModel, sbModel]]
        
        //MARK: 配置tableVIew
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = 50
        
//        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("aaaaaaa")
    }

}


//
//  ViewController.swift
//  XKTagsView
//
//  Created by kenneth on 06/29/2021.
//  Copyright (c) 2021 kenneth. All rights reserved.
//

import UIKit
import XKTagsView

class ViewController: UIViewController {

    let tagsView = XKTagsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tagsView)
        tagsView.frame = CGRectMake(10, 100, view.bounds.width-32, 100)
        tagsView.flagSize = CGSize(width: 16, height: 16)
        tagsView.flagImage = .init(named: "notice")!
        tagsView.tags = ["哈", "佬", "啊"]
        tagsView.enableShowFlag = true
        tagsView.xk_updateFlagIndexes([0, 2])
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tagsView.xk_refreshView()
        tagsView.frame.size.height = tagsView.xk_viewHeight()
    }

}


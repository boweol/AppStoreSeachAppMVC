//
//  TabbarController.swift
//  AppStoreSearchApp
//
//  Created by isens on 27/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 2 // 검색 탭으로 이동
    }
}

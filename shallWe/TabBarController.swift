//
//  TabBarController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/08/11.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class TabBarController: UITabBarController {

    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //夕方画面を初期選択にする。
        self.selectedIndex = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

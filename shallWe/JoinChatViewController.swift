//
//  JoinChatViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/08/02.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit

class JoinChatViewController: UIViewController {

    var roomName = String()
    var roomID = String()
    var pathToImage = String()
    var roomAddmitNum = String()
    var roomDetail = String()

    //ルーム情報のパラメータ
    @IBOutlet var RoomImage: UIImageView!
    @IBOutlet var RoomName: String!
    @IBOutlet var RoomDetail: String!
    @IBOutlet var RoomAddmitNum: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRoomInfo()
    }

    func setRoomInfo(){
        //roomImageのUrl作成
        let roomImageUrl = URL(string:self.pathToImage as String)!
        //Cashをとっている
        self.RoomImage.sd_setImage(with: roomImageUrl, completed: nil)

        self.RoomName = self.roomName
        self.RoomDetail = self.roomDetail
        self.RoomAddmitNum = self.roomAddmitNum
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

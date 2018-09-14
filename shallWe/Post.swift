//
//  Post.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/06/09.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit

class Post: NSObject {

    var roomImage:String = String()
    //住所が入る変数
    var country:String = String()
    var administrativeArea:String = String()
    var subAdministrativeArea:String = String()
    var locality:String = String()
    var subLocality:String = String()
    var thoroughfare:String = String()
    var subThoroughfare:String = String()

    //部屋情報が入る変数
    var pathToImage:String!
    var roomID:String!
    var roomName:String!
    var roomDetail:String!
    var roomAddmitNum:String!
    var ownerUserID:String!
    var memberNum:String!
    var key:String!

}

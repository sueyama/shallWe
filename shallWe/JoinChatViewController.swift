//
//  JoinChatViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/08/02.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class JoinChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid

    var roomName = String()
    var roomID = String()
    var pathToImage = String()
    var roomAddmitNum = String()
    var roomDetail = String()
    var ownerUserID = String()
    
    var userImage: String!

    //ルーム情報のパラメータ
    @IBOutlet var RoomImage: UIImageView!
    @IBOutlet var RoomName: UILabel!
    @IBOutlet var RoomDetail: UILabel!
    @IBOutlet var RoomAddmitNum: UILabel!
    
    @IBOutlet var ownerImage: UIImageView!
    @IBOutlet var ownerName: UILabel!
    
    @IBOutlet var memberCollection: UICollectionView!
    var member_posts = [Member]()
    var member_posst = Member()
    
    var userInfo = [LoginUserPost]()
    var userInfoMap = LoginUserPost()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRoomInfo()
        getOwnerInfo()
        getMemberInfo()
        getUserInfo()
    }

    func setRoomInfo(){
        //roomImageのUrl作成
        let roomImageUrl = URL(string:self.pathToImage as String)!
        //Cashをとっている
        self.RoomImage.sd_setImage(with: roomImageUrl, completed: nil)

        self.RoomName.text = self.roomName
        self.RoomDetail.text = self.roomDetail
        self.RoomAddmitNum.text = self.roomAddmitNum
    }
    
    //オーナールームのデータ取得メソッド
    func getOwnerInfo(){
        
        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
        ref.child("Users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            if(snap.exists()){
                let postsSnap = snap.value as! [String:AnyObject]
                for (_,ownerPost) in postsSnap{
                    //roomID取得
                    if let userID = ownerPost["userID"] as? String, let pathToImage = ownerPost["pathToImage"] as? String, let userName = ownerPost["userName"] as? String{
                        //Databaseのものと比較してオーナーユーザ情報を取得
                        if (userID == self.ownerUserID){
                            //ログインユーザの情報設定
                            self.ownerImage.sd_setImage(with: URL(string: pathToImage), completed: nil)
                            self.ownerName.text = userName
                        }
                    }
                }
            }
        })
    }

    //メンバールームのデータ取得メソッド
    func getMemberInfo(){
        
        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
        ref.child("Member").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            if(snap.exists()){
                let postsSnap = snap.value as! [String:AnyObject]
                for (_,memberPost) in postsSnap{
                    //roomID取得
                    if let userID = memberPost["userID"] as? String, let userImage = memberPost["userImage"] as? String, let roomId = memberPost["roomId"] as? String{
                        //Databaseのものと比較してオーナーユーザ情報を取得
                        //owner_posstの中に入れていく
                        self.member_posst.userID = userID
                        self.member_posst.userImage = userImage
                        self.member_posst.roomId = roomId
                        
                        //Databaseのものと比較して住所が同じものだけを入れる
                        if (self.member_posst.roomId == self.roomID)
                        {
                            self.member_posts.append(self.member_posst)
                            self.memberCollection.reloadData()
                        }
                    }
                }
            }
        })
        
    }

    //メンバールームのデータ取得メソッド
    func getUserInfo(){
        
        let ref = Database.database().reference()
        //Usersの配下にあるデータを取得する
        ref.child("Users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            let postsSnap = snap.value as! [String:AnyObject]
            for (_,userInfo) in postsSnap{
                //userId取得
                if let userID = userInfo["userID"] as? String{
                    //post初期化
                    self.userInfoMap = LoginUserPost()
                    // ,で区切ってpathToImage,userID,userName・・・取得
                    if let pathToImage = userInfo["pathToImage"] as? String,
                        let userName = userInfo["userName"] as? String {
                        //posstの中に入れていく
                        self.userInfoMap.pathToImage = pathToImage
                        self.userInfoMap.userID = userID
                        self.userInfoMap.userName = userName
                        if (self.userInfoMap.userID == self.uid)
                        {
                            //ログインユーザの情報設定
                            self.userImage = self.userInfoMap.pathToImage
                            
                        }
                    }
                    
                }
            }
            
            
        })
        
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.member_posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Cell1というIdentifierをつける
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath)
        
        //メンバーの写真
        //Tagに「1」を振っている
        let roomImageView = cell.contentView.viewWithTag(1) as! UIImageView
        //roomImageViewにタグを付ける
        let roomImageUrl = URL(string:self.member_posts[indexPath.row].userImage as String)!
        //Cashをとっている
        roomImageView.sd_setImage(with: roomImageUrl, completed: nil)
        
        return cell

    }


    @IBAction func joinButton(_ sender: Any) {
        joinRoom()
    }

    func joinRoom(){
        //FireBaseのDatabaseを宣言
        let ref = Database.database().reference()
        let key = ref.child("Member").childByAutoId().key
        
        AppDelegate.instance().dismissActivityIndicator()
        //feedの中に、キー値と値のマップを入れている
        //roomId,roomName,roomDetail,roomAddmitNum,ownerUserID,住所全体,
        let feed = ["roomID":self.roomID,"roomImage":self.pathToImage,"roomName":self.roomName,"roomDetail":self.roomDetail,"roomAddmitNum":self.roomAddmitNum,"userImage":self.userImage,"userID":self.uid!] as [String:Any]
                    
        //feedにkey値を付ける
        let postFeed = ["\(key)":feed]
        //DatabaseのRoomsの下にすべて入れる
        ref.child("Member").updateChildValues(postFeed)
        //indicatorを止める
        AppDelegate.instance().dismissActivityIndicator()
        //画面遷移
        self.performSegue(withIdentifier: "privateChat", sender: nil)
        
    }

    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        if(segue.identifier == "joinChat"){
            let privateChatVC = segue.destination as! PrivateChatViewController
            
            //RoomIDを渡したい
            privateChatVC.roomID = self.roomID
            //RoomNameを渡したい
            privateChatVC.roomName = self.roomName
            //PathToImageを渡したい profile画像用URL
            privateChatVC.pathToImage = self.pathToImage
            //roomAddmitNumを渡したい
            privateChatVC.roomAddmitNum = self.roomAddmitNum
            //roomDetailを渡したい
            privateChatVC.roomDetail = self.roomDetail

        }
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

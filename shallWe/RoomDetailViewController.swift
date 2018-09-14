//
//  RoomDetailViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/08/02.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class RoomDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    
    var roomName = String()
    var roomID = String()
    var pathToImage = String()
    var roomAddmitNum = String()
    var memberNum = String()
    var roomDetail = String()
    var ownerUserID = String()
    
    var userImage: String!
    var userName = String()
    
    @IBOutlet var RoomImage: UIImageView!
    @IBOutlet var RoomName: UILabel!
    @IBOutlet var RoomDetail: UILabel!
    @IBOutlet var RoomAddmitNum: UILabel!

    @IBOutlet var ownerImage: UIImageView!
    @IBOutlet var ownerName: UILabel!

    @IBOutlet var memberCollection: UICollectionView!

    @IBOutlet weak var statusBar: UILabel!
    @IBOutlet weak var closeButton: UIBarButtonItem!

    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var member_posts = [Member]()
    var member_posst = Member()
    
    var userInfo = [LoginUserPost]()
    var userInfoMap = LoginUserPost()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editUI()
        
        // delegateを設定する
        self.memberCollection.dataSource = self
        self.memberCollection.delegate = self

        setRoomInfo()
        getOwnerInfo()
        getMemberInfo()
        getUserInfo()
    }
    
    func setRoomInfo(){
        //roomImageのUrl作成
        let roomImageUrl = URL(string:self.pathToImage as String)
        //Cashをとっている
        self.RoomImage.sd_setImage(with: roomImageUrl, completed: nil)
        
        self.RoomName.text = self.roomName
        self.RoomDetail.text = self.roomDetail
        self.RoomAddmitNum.text = self.memberNum + "/" + self.roomAddmitNum
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
                // member_postsの初期化
                self.member_posts = [Member]()
                for (_,memberPost) in postsSnap{
                    // member_posstの初期化
                    self.member_posst = Member()
                    //roomID取得
                    if let userID = memberPost["userID"] as? String, let userImage = memberPost["userImage"] as? String, let roomId = memberPost["roomID"] as? String, let userNAME = memberPost["userName"] as? String{
                        //Databaseのものと比較してオーナーユーザ情報を取得
                        //owner_posstの中に入れていく
                        self.member_posst.userID = userID
                        self.member_posst.userImage = userImage
                        self.member_posst.roomId = roomId
                        self.member_posst.userName = userNAME
                        
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
        
        //メンバーの名前
        //Tagに「2」を振っている
        let memberName = cell.contentView.viewWithTag(2) as! UILabel
        memberName.text = self.member_posts[indexPath.row].userName

        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func editUI(){
        //各種パーツの色設定
        statusBar.backgroundColor = UIColor(red: 50/255, green: 58/255, blue: 67/255, alpha: 1.0) // dark black
        closeButton.tintColor = UIColor.white
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

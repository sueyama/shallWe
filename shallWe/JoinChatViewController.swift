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
    var memberNum = String()
    var roomKey = String()
    
    var userImage: String!
    var userName = String()
    
    var buttonSwitch = false

    //ルーム情報のパラメータ
    @IBOutlet var RoomImage: UIImageView!
    @IBOutlet var RoomName: UILabel!
    @IBOutlet var RoomDetail: UILabel!
    @IBOutlet var RoomAddmitNum: UILabel!

    @IBOutlet var ownerImage: UIImageView!
    @IBOutlet var ownerName: UILabel!
    
    @IBOutlet var memberCollection: UICollectionView!
    @IBOutlet weak var statusBar: UIView!
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var joinButton: UIButton!

    @IBOutlet var joinButtonUi: UIButton!
    
    @IBAction func joinButton(_ sender: Any) {
        joinRoom()
    }
    @IBAction func seniButton(_ sender: Any) {
        seniRoom()
    }

    //右上の閉じるボタン押下時の挙動
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    var member_posts = [Member]()
    var member_posst = Member()
    
    var userInfo = [LoginUserPost]()
    var userInfoMap = LoginUserPost()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let roomImageUrl = URL(string:self.pathToImage as String)!
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
                            if(self.ownerUserID == self.uid){
                                self.buttonSwitch = true
                            }
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
                    if let userID = memberPost["userID"] as? String, let userImage = memberPost["userImage"] as? String, let roomId = memberPost["roomID"] as? String, let userName = memberPost["userName"] as? String{
                        //Databaseのものと比較してオーナーユーザ情報を取得
                        //owner_posstの中に入れていく
                        self.member_posst.userID = userID
                        self.member_posst.userImage = userImage
                        self.member_posst.roomId = roomId
                        self.member_posst.userName = userName
                        
                        //Databaseのものと比較して住所が同じものだけを入れる
                        if (self.member_posst.roomId == self.roomID)
                        {
                            self.member_posts.append(self.member_posst)
                            self.memberCollection.reloadData()
                            if(self.member_posst.userID == self.uid){
                                self.buttonSwitch = true
                            }
                        }
                    }
                }
            }
            self.setButton()
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
                            self.userName = self.userInfoMap.userName
                        }
                    }
                    
                }
            }
            
            
        })
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
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



    func joinRoom(){
        //FireBaseのDatabaseを宣言
        let ref = Database.database().reference()
        let key = ref.child("Member").childByAutoId().key
        
        self.memberNum = String(Int(self.memberNum)! + 1)
        
        AppDelegate.instance().dismissActivityIndicator()
        //feedの中に、キー値と値のマップを入れている
        //roomId,roomName,roomDetail,roomAddmitNum,ownerUserID,住所全体,
        let feed = ["roomID":self.roomID,"roomImage":self.pathToImage,"roomName":self.roomName,"roomDetail":self.roomDetail,"roomAddmitNum":self.roomAddmitNum,"memberNum":self.memberNum,"userImage":self.userImage,"userID":self.uid!,"userName":self.userName,"ownerUserID":self.ownerUserID] as [String:Any]
                    
        //feedにkey値を付ける
        let postFeed = ["\(key)":feed]
        //DatabaseのMemberの下にすべて入れる
        ref.child("Member").updateChildValues(postFeed)

        
        let feed2 = ["roomID":self.roomID,"pathToImage":self.pathToImage,"roomName":self.roomName,"roomDetail":self.roomDetail,"roomAddmitNum":self.roomAddmitNum,"memberNum":self.memberNum,"ownerUserID":self.ownerUserID] as [String:Any]
        
        //feedにkey値を付ける
        let postFeed2 = [self.roomID:feed2]
        //Databaseのroomsの下に更新する
        ref.child("Rooms").updateChildValues(postFeed2)

        //indicatorを止める
        AppDelegate.instance().dismissActivityIndicator()
        //画面遷移
        self.performSegue(withIdentifier: "joinChat", sender: nil)
        
    }

    func seniRoom(){
        //画面遷移
        self.performSegue(withIdentifier: "joinChat", sender: nil)
        
    }

    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        if(segue.identifier == "joinChat"){
            let privateChatVC = segue.destination as! PrivateChatViewController
            
            //RoomIDを渡したい
            privateChatVC.roomID = self.roomID
            //RoomNameを渡したい
            privateChatVC.roomName = self.roomName
            //PathToImageを渡したい profile画像用URL
            //privateChatVC.pathToImage = self.pathToImage
            //roomAddmitNumを渡したい
            privateChatVC.roomAddmitNum = self.roomAddmitNum
            //roomDetailを渡したい
            privateChatVC.roomDetail = self.roomDetail
            //memberNumを渡したい
            privateChatVC.memberNum = self.memberNum

        }
    }

    func setButton(){
        // UIButtonのインスタンスを作成する
        let button = UIButton(type: UIButtonType.system)
        
        if(self.buttonSwitch){
            // ボタンを押した時に実行するメソッドを指定
            button.addTarget(self, action: #selector(seniButton(_:)), for: UIControlEvents.touchUpInside)
            // ラベルを設定する
            button.setTitle("ルームへ", for: UIControlState.normal)

        }else{
            // ボタンを押した時に実行するメソッドを指定
            button.addTarget(self, action: #selector(joinButton(_:)), for: UIControlEvents.touchUpInside)
            // ラベルを設定する
            button.setTitle("参加", for: UIControlState.normal)

        }
        
        // サイズを変更する
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        // 任意の場所に設置する
        button.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height*5/6)
        // 文字色を変える
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        // 背景色を変える
        button.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.6, alpha: 1)
        // 枠の太さを変える
        button.layer.borderWidth = 1.0
        // 枠の色を変える
        button.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        // 枠に丸みをつける
        button.layer.cornerRadius = 25
        // 影の濃さを決める
        button.layer.shadowOpacity = 0.5
        // 影のサイズを決める
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        // ボタンが押されたときの文字色
        button.setTitleColor(UIColor.red, for: UIControlState.highlighted)
        // viewに追加する
        self.view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //見た目の設定
    func editUI(){
        //各種パーツの色設定
        statusBar.backgroundColor = UIColor(red: 50/255, green: 58/255, blue: 67/255, alpha: 1.0) // dark black
        closeButton.tintColor = UIColor.white
        //joinButton.backgroundColor =  UIColor(red: 50/255, green: 58/255, blue: 67/255, alpha: 1.0) // dark black
        //joinButton.layer.borderWidth = 0 // 枠線の幅
        //joinButton.layer.borderColor = UIColor.red.cgColor // 枠線の色
        //joinButton.layer.cornerRadius = 18.0 // 角丸のサイズ
        //joinButton.setTitleColor(UIColor(red: 255/255, green: 233/255, blue: 51/255, alpha: 1.0),for: UIControlState.normal) // タイトルの色

    }

}

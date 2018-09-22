//
//  RoomsViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/06/08.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class TopViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    //ログインユーザの情報のパラメータ
    @IBOutlet var topLoginUserImage: UIImageView!
    @IBOutlet var topLoginUserName: UILabel!
    var userInfo = [LoginUserPost]()
    @IBOutlet var ownerRoomTableView: UITableView!
    @IBOutlet var memberRoomTableView: UITableView!

    @IBAction func profileEdit(_ sender: Any) {
        //let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "profileEdit")
        //present(nextVC!,animated:true,completion: nil)
        //画面遷移
        performSegue(withIdentifier: "profileEdit", sender: nil)
    }
    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!

    //比べる用
    var address:String = String()
    
    var owner_posts = [Post]()
    var member_posts = [Post]()
    
    //住所　近い順
    var country_Array = [String]()
    var administrativeArea_Array = [String]()
    var subAdministrativeArea_Array = [String]()
    var locality_Array = [String]()
    var subLocality_Array = [String]()
    var thoroughfare_Array = [String]()
    var subThoroughfare_Array = [String]()

    var userInfoMap = LoginUserPost()
    var owner_posst = Post()
    var member_posst = Post()
    var posst = Post()

    // 遷移用の格納変数
    var seni_roomID = String()
    var seni_roomName = String()
    var seni_pathToImage = String()
    var seni_roomAddmitNum = String()
    var seni_roomDetail = String()
    var seni_ownerUserID = String()
    var seni_memberNum = String()
    var seni_roomKey = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // delegateを設定する
        ownerRoomTableView.dataSource = self
        ownerRoomTableView.delegate = self
        
        memberRoomTableView.dataSource = self
        memberRoomTableView.delegate = self

        
        // cellに画像を描画した際に下線を左端まで表示する
        self.ownerRoomTableView.separatorInset = UIEdgeInsets.zero
        self.memberRoomTableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //ログインユーザのデータを引っ張ってくるメソッド呼び出し
        getLoginUserInfo()

        //オーナールームのデータを引っ張ってくるメソッド呼び出し
        getOwnerRoomsInfo()

        //メンバールームのデータを引っ張ってくるメソッド呼び出し
        getMemberRoomsInfo()

    }

    //Postsの取得
    func getLoginUserInfo(){
        
        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
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
                            self.topLoginUserImage.sd_setImage(with: URL(string: pathToImage), completed: nil)
                            self.topLoginUserName.text = userName
                            
                        }
                    }
                    
                }
            }
            
            
        })
    }

    //オーナールームのデータ取得メソッド
    func getOwnerRoomsInfo(){
        
        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
        ref.child("Rooms").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapB) in
            if(snapB.exists()){
                let postsSnap = snapB.value as! [String:AnyObject]
                //owner_posts初期化
                self.owner_posts = [Post]()
                for (_,ownerPost) in postsSnap{
                    //roomID取得
                    if let roomID = ownerPost["roomID"] as? String{
                        //owner_posst初期化
                        self.owner_posst = Post()
                        // ,で区切ってpathToImage,roomName,roomID,roomDeteil,roomAddmitNum,ownerUserID・・・取得
                        if let pathToImage = ownerPost["pathToImage"] as? String,
                            let roomName = ownerPost["roomName"] as? String,
                            let roomDetail = ownerPost["roomDetail"] as? String,
                            let roomAddmitNum = ownerPost["roomAddmitNum"] as? String,
                            let memberNum = ownerPost["memberNum"] as? String,
                            let ownerUserID = ownerPost["ownerUserID"] as? String {
                            //owner_posstの中に入れていく
                            self.owner_posst.pathToImage = pathToImage
                            self.owner_posst.roomID = roomID
                            self.owner_posst.roomName = roomName
                            self.owner_posst.roomDetail = roomDetail
                            self.owner_posst.roomAddmitNum = roomAddmitNum
                            self.owner_posst.ownerUserID = ownerUserID
                            self.owner_posst.memberNum = memberNum
                            
                            //Databaseのものと比較して住所が同じものだけを入れる
                            if (self.owner_posst.ownerUserID == self.uid)
                            {
                                self.owner_posts.append(self.owner_posst)
                                self.ownerRoomTableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
        })
    }

    //メンバールームのデータ取得メソッド
    func getMemberRoomsInfo(){
        
        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
        ref.child("Member").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapC) in            if(snapC.exists()){
                let postsSnapC = snapC.value as! [String:AnyObject]
                //member_posts初期化
                self.member_posts = [Post]()
                for (_,memberaaPost) in postsSnapC{
                    //roomID取得
                    if let userID = memberaaPost["userID"] as? String{
                        //member_posst初期化
                        self.member_posst = Post()
                        if(userID == self.uid){
                            // ,で区切ってpathToImage,roomName,roomID,roomDeteil,roomAddmitNum,ownerUserID・・・取得
                            if  let roomID = memberaaPost["roomID"] as? String,
                                let roomImage = memberaaPost["roomImage"] as? String,
                                let roomName = memberaaPost["roomName"] as? String,
                                let roomDetail = memberaaPost["roomDetail"] as? String,
                                let memberNum = memberaaPost["memberNum"] as? String,
                                let roomAddmitNum = memberaaPost["roomAddmitNum"] as? String {
                                //owner_posstの中に入れていく
                                self.member_posst.roomImage = roomImage
                                self.member_posst.roomID = roomID
                                self.member_posst.roomName = roomName
                                self.member_posst.roomDetail = roomDetail
                                self.member_posst.roomAddmitNum = roomAddmitNum
                                self.member_posst.memberNum = memberNum
                                
                                self.member_posts.append(self.member_posst)
                                self.memberRoomTableView.reloadData()
                            }
                            
                        }
                        
                    }
                }
            }
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 1 {

            self.seni_roomID = self.owner_posts[indexPath.row].roomID
            self.seni_roomName = self.owner_posts[indexPath.row].roomName
            self.seni_pathToImage = self.owner_posts[indexPath.row].pathToImage
            self.seni_roomAddmitNum = self.owner_posts[indexPath.row].roomAddmitNum
            self.seni_roomDetail = self.owner_posts[indexPath.row].roomDetail
            self.seni_ownerUserID = self.owner_posts[indexPath.row].ownerUserID
            self.seni_memberNum = self.owner_posts[indexPath.row].memberNum
            //self.seni_roomKey = self.owner_posts[indexPath.row].key

        }else if tableView.tag == 2 {
            
            self.seni_roomID = self.member_posts[indexPath.row].roomID
            self.seni_roomName = self.member_posts[indexPath.row].roomName
            self.seni_pathToImage = self.member_posts[indexPath.row].roomImage
            self.seni_roomAddmitNum = self.member_posts[indexPath.row].roomAddmitNum
            self.seni_roomDetail = self.member_posts[indexPath.row].roomDetail
            self.seni_ownerUserID = self.member_posts[indexPath.row].ownerUserID
            self.seni_memberNum = self.member_posts[indexPath.row].memberNum
            self.seni_roomKey = self.member_posts[indexPath.row].key

        }
        
        //画面遷移
        performSegue(withIdentifier: "privateChat", sender: tableView.tag)
        
    }
    
    
    override func prepare(for segue:UIStoryboardSegue,sender: Any?){
        
        if(segue.identifier == "privateChat"){
            let privateChatVC = segue.destination as! PrivateChatViewController

            //RoomIDを渡したい
            privateChatVC.roomID = self.seni_roomID
            //RoomNameを渡したい
            privateChatVC.roomName = self.seni_roomName
           //PathToImageを渡したい profile画像用URL
            privateChatVC.pathToImage = self.seni_pathToImage
            //roomAddmitNumを渡したい
            privateChatVC.roomAddmitNum = self.seni_roomAddmitNum
            //roomDetailを渡したい
            privateChatVC.roomDetail = self.seni_roomDetail
            //memberNumを渡したい
            privateChatVC.memberNum = self.seni_memberNum
            //ownerUserIDを渡したい
            //privateChatVC.ownerUserID = self.seni_ownerUserID
            //keyを渡したい
            //privateChatVC.key = self.seni_roomKey


        }
        
        if(segue.identifier == "profileEdit"){
            let profileEditVC = segue.destination as! ProfileEditViewController
            
            //uidを渡したい
            profileEditVC.uid = self.uid
            //profileImageを渡したい profile画像用URL
            profileEditVC.profileImage = self.userInfoMap.pathToImage
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 {
            //Cell1というIdentifierをつける
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            
            //ルームの写真
            //Tagに「3」を振っている
            let roomImageView = cell.contentView.viewWithTag(3) as! UIImageView
            //ownernameにタグを付ける
            let roomImageUrl = URL(string:self.owner_posts[indexPath.row].pathToImage as String)!
            //Cashをとっている
            roomImageView.sd_setImage(with: roomImageUrl, completed: nil)
            
            //ルーム名
            //Tagに「4」を振っている
            let roomNameLabel = cell.contentView.viewWithTag(4) as! UILabel
            roomNameLabel.text = self.owner_posts[indexPath.row].roomName
            
            //ルーム詳細
            //Tagに「5」を振っている
            let roomDetailLabel = cell.contentView.viewWithTag(5) as! UILabel
            roomDetailLabel.text = self.owner_posts[indexPath.row].roomDetail

            //ルーム人数
            //Tagに「6」を振っている
            let roomAddmitNumLabel = cell.contentView.viewWithTag(6) as! UILabel
            roomAddmitNumLabel.text = self.owner_posts[indexPath.row].memberNum + "/" + self.owner_posts[indexPath.row].roomAddmitNum


            return cell
            
        }else if tableView.tag == 2{
            //Cell2というIdentifierをつける
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            
            //ルームの写真
            //Tagに「7」を振っている
            let roomImageView = cell.contentView.viewWithTag(7) as! UIImageView
            //ownernameにタグを付ける
            let roomImageUrl = URL(string:self.member_posts[indexPath.row].roomImage as String)!
            //Cashをとっている
            roomImageView.sd_setImage(with: roomImageUrl, completed: nil)
            
            //ルーム名
            //Tagに「8」を振っている
            let roomNameLabel = cell.contentView.viewWithTag(8) as! UILabel
            roomNameLabel.text = self.member_posts[indexPath.row].roomName
            
            //ルーム詳細
            //Tagに「9」を振っている
            let roomDetailLabel = cell.contentView.viewWithTag(9) as! UILabel
            roomDetailLabel.text = self.member_posts[indexPath.row].roomDetail
            
            //ルーム人数
            //Tagに「10」を振っている
            let roomAddmitNumLabel = cell.contentView.viewWithTag(10) as! UILabel
            roomAddmitNumLabel.text = self.member_posts[indexPath.row].memberNum + "/" + self.member_posts[indexPath.row].roomAddmitNum
            
            return cell

        }
        return tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1 {
            return self.owner_posts.count
        }else if tableView.tag == 2 {
            return self.member_posts.count
        }
        
        return 0
    }

    // Cell の高さを60にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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

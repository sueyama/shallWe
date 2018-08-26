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
    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
    
    //ログインユーザの情報のパラメータ
    @IBOutlet var topLoginUserImage: UIImageView!
    @IBOutlet var topLoginUserName: UILabel!
    
    //比べる用
    var address:String = String()

    var owner_posts = [Post]()
    var member_posts = [Post]()

    var userInfo = [LoginUserPost]()
    @IBOutlet var ownerRoomTableView: UITableView!
    @IBOutlet var memberRoomTableView: UITableView!

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

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                            let ownerUserID = ownerPost["ownerUserID"] as? String {
                            //owner_posstの中に入れていく
                            self.owner_posst.pathToImage = pathToImage
                            self.owner_posst.roomID = roomID
                            self.owner_posst.roomName = roomName
                            self.owner_posst.roomDetail = roomDetail
                            self.owner_posst.roomAddmitNum = roomAddmitNum
                            self.owner_posst.ownerUserID = ownerUserID
                            
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
        ref.child("Rooms").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapC) in            if(snapC.exists()){
                let postsSnap = snapC.value as! [String:AnyObject]
                for (_,memberaaPost) in postsSnap{
                    ref.child("RoomsMenber/" + (memberaaPost["ownerUserID"] as? String)!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapB) in
                        let userSnap = snapC.value as! [String:AnyObject]
                        for (_,memberaaPost) in userSnap{
                            //roomID取得
                            if let userIDB = memberaaPost["userID"] as? String{
                                if(userIDB == self.uid){
                                    //member_posst初期化
                                    self.member_posst = Post()
                                    // ,で区切ってpathToImage,roomName,roomID,roomDeteil,roomAddmitNum,ownerUserID・・・取得
                                    if  let pathToImage = memberaaPost["pathToImage"] as? String,
                                        let roomID = memberaaPost["roomID"] as? String,
                                        let roomName = memberaaPost["roomName"] as? String,
                                        let roomDetail = memberaaPost["roomDetail"] as? String,
                                        let roomAddmitNum = memberaaPost["roomAddmitNum"] as? String,
                                        let ownerUserID = memberaaPost["ownerUserID"] as? String {
                                        //owner_posstの中に入れていく
                                        self.member_posst.pathToImage = pathToImage
                                        self.member_posst.roomID = roomID
                                        self.member_posst.roomName = roomName
                                        self.member_posst.roomDetail = roomDetail
                                        self.member_posst.roomAddmitNum = roomAddmitNum
                                        self.member_posst.ownerUserID = ownerUserID
                                        
                                        self.member_posts.append(self.member_posst)
                                        self.memberRoomTableView.reloadData()
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    })
                }
            }
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 1 {
            posst = owner_posst
        }else if tableView.tag == 2 {
            posst = member_posst
        }
        //画面遷移
        performSegue(withIdentifier: "privateChat", sender: indexPath)
        
    }
    
    
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        if(segue.identifier == "privateChat"){
            let privateChatVC = segue.destination as! PrivateChatViewController

            //RoomIDを渡したい
            privateChatVC.roomID = self.posst.roomID
            //RoomNameを渡したい
            privateChatVC.roomName = self.posst.roomName
            //PathToImageを渡したい profile画像用URL
            privateChatVC.pathToImage = profileImage.absoluteString!
        }
        
        if(segue.identifier == "profileEdit"){
            let profileEditVC = segue.destination as! ProfileEditViewController
            
            //uidを渡したい
            profileEditVC.uid = self.uid
            //profileImageを渡したい profile画像用URL
            //profileEditVC.profileImage = self.profileImage! as NSURL
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 {
            //Cell1というIdentifierをつける
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            
            //ルームの写真
            //Tagに「0」を振っている
            let roomImageView = cell.contentView.viewWithTag(0) as! UIImageView
            //ownernameにタグを付ける
            let roomImageUrl = URL(string:self.owner_posts[indexPath.row].pathToImage as String)!
            //Cashをとっている
            roomImageView.sd_setImage(with: roomImageUrl, completed: nil)
            
            //ルーム名
            //Tagに「1」を振っている
            let roomNameLabel = cell.contentView.viewWithTag(1) as! UILabel
            roomNameLabel.text = self.owner_posts[indexPath.row].roomName
            
            //ルーム詳細
            //Tagに「2」を振っている
            let roomDetailLabel = cell.contentView.viewWithTag(2) as! UILabel
            roomDetailLabel.text = self.owner_posts[indexPath.row].roomDetail

            //ルーム人数
            //Tagに「3」を振っている
            let roomAddmitNumLabel = cell.contentView.viewWithTag(3) as! UILabel
            roomAddmitNumLabel.text = self.owner_posts[indexPath.row].roomAddmitNum
            
            return cell
            
        }else if tableView.tag == 2{
            //Cell2というIdentifierをつける
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            
            //ルームの写真
            //Tagに「0」を振っている
            let roomImageView = cell.contentView.viewWithTag(0) as! UIImageView
            //ownernameにタグを付ける
            let roomImageUrl = URL(string:self.member_posts[indexPath.row].pathToImage as String)!
            //Cashをとっている
            roomImageView.sd_setImage(with: roomImageUrl, completed: nil)
            
            //ルーム名
            //Tagに「1」を振っている
            let roomNameLabel = cell.contentView.viewWithTag(1) as! UILabel
            roomNameLabel.text = self.member_posts[indexPath.row].roomName
            
            //ルーム詳細
            //Tagに「2」を振っている
            let roomDetailLabel = cell.contentView.viewWithTag(2) as! UILabel
            roomDetailLabel.text = self.member_posts[indexPath.row].roomDetail
            
            //ルーム人数
            //Tagに「3」を振っている
            let roomAddmitNumLabel = cell.contentView.viewWithTag(3) as! UILabel
            roomAddmitNumLabel.text = self.member_posts[indexPath.row].roomAddmitNum
            
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

    // Cell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    
    @IBAction func profileEdit(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "profilePage")
        present(nextVC!,animated:true,completion: nil)
        //画面遷移
        //performSegue(withIdentifier: "profileEdit", sender: nil)
    }
     
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

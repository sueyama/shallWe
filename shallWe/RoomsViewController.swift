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

class RoomsViewController2: UIViewController, UITableViewDelegate,UITableViewDataSource {
    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
    //比べる用
    var address:String = String()
    
    var posts = [Post]()
    
    @IBOutlet var tableView: UITableView!
    
    var country_Array = [String]()
    var administrativeArea_Array = [String]()
    var subAdministrativeArea_Array = [String]()
    var locality_Array = [String]()
    var subLocality_Array = [String]()
    var thoroughfare_Array = [String]()
    var subThoroughfare_Array = [String]()
    var pathToImage_Array = [String]()
    var roomName_Array = [String]()
    var userID_Array = [String]()
    var posst = Post()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //データを引っ張ってくるメソッド呼び出し
        fetchPosts()
    }
    
    //Postsの取得
    func fetchPosts(){
        
        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
        ref.child("Rooms").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            let postsSnap = snap.value as! [String:AnyObject]
            for (_,post) in postsSnap{
                //userId取得
                if let userID = post["userID"] as? String{
                    //post初期化
                    self.posst = Post()
                    // ,で区切ってpathToImage,postId,roomName・・・取得
                    if let pathToImage = post["pathToImage"] as? String,
                        let postID = post["postID"] as? String, let roomName = post["roomName"] as? String ,
                        let country = post["country"] as? String,
                        let administrativeArea = post["administrativeArea"] as? String,
                        let subAdministrativeArea = post["subAdministrativeArea"] as? String,
                        let locality = post["locality"] as? String, let subLocality = post["subLocality"] as? String,
                        let thoroughfare = post["thoroughfare"] as? String {
                        //posstの中に入れていく
                        self.posst.pathToImage = pathToImage
                        self.posst.userID = userID
                        self.posst.roomName = roomName
                        self.posst.country = country
                        self.posst.administrativeArea = administrativeArea
                        self.posst.subAdministrativeArea = subAdministrativeArea
                        self.posst.locality = locality
                        self.posst.subLocality = subLocality
                        //roomName_Arrayに入れる
                        self.roomName_Array.append(self.posst.roomName)
                        print(self.posst.country + self.posst.administrativeArea + self.posst.subAdministrativeArea
                            + self.posst.locality + self.posst.subLocality)
                        //Databaseのものと比較して住所が同じものだけを入れる
                        if ((self.posst.country + self.posst.administrativeArea + self.posst.subAdministrativeArea
                            + self.posst.locality + self.posst.subLocality) == self.address)
                        {
                            self.posts.append(self.posst)
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            }
            
            
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //画面遷移
        performSegue(withIdentifier: "privateChat", sender: indexPath)
        
    }
    
    
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        if(segue.identifier == "privateChat"){
            let privateChatVC = segue.destination as! PrivateChatViewController
            //Roomsの中の全てのAddressを足したもの→これとaddressを比べる
            let fromDBAddress = self.posst.country + self.posst.administrativeArea + self.posst.subAdministrativeArea
                + self.posst.locality + self.posst.subLocality
            print(address)
            //RoomNameを渡したい
            privateChatVC.roomName = self.posst.roomName
            //住所を渡したい
            privateChatVC.fromDBAddress = fromDBAddress
            //PathToImageを渡したい profile画像用URL
            privateChatVC.pathToImage = profileImage.absoluteString!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //CellというIdentifierをつける
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //オーナーの名前(現在はUserIDでとっている)
        //Tagに「1」を振っている
        let ownerNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        //ownernameにタグを付ける
        ownerNameLabel.text = self.posts[indexPath.row].userID
        
        print(self.posts[indexPath.row].userID)
        
        //プロフィール
        //Tagに「2」を振っている
        let profileImageView = cell.contentView.viewWithTag(2) as! UIImageView
        let profileImageUrl = URL(string:self.posts[indexPath.row].pathToImage as String)!
        //Cashをとっている
        profileImageView.sd_setImage(with: profileImageUrl, completed: nil)
        
        //部屋の名前
        //Tagに「3」を振っている
        let roomNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        roomNameLabel.text = self.posts[indexPath.row].roomName
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    // Cell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
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

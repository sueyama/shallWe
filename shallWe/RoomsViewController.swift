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

class RoomsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {

    //tableViewとsearchBarの定義
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!

    //比べる用
    var address:String = String()
    var posts = [Post]()
    var postsCopy = [Post]()
    
    //住所　近い順
    var country_Array = [String]()
    var administrativeArea_Array = [String]()
    var subAdministrativeArea_Array = [String]()
    var locality_Array = [String]()
    var subLocality_Array = [String]()
    var thoroughfare_Array = [String]()
    var subThoroughfare_Array = [String]()
    
    var posst = Post()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.searchBar.barTintColor = UIColor(red: 50/255, green: 58/255, blue: 67/255, alpha: 1.0) // dark black
        // cellに画像を描画した際に下線を左端まで表示する
        self.tableView.separatorInset = UIEdgeInsets.zero
        //デリゲート先を自分に設定する。
        self.searchBar.delegate = self
        
        //何も入力されていなくてもReturnキーを押せるようにする。
        self.searchBar.enablesReturnKeyAutomatically = false

        // delegateを設定する
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //ルームのデータを引っ張ってくるメソッド呼び出し
        getRoomsInfo()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ルームのデータを引っ張ってくるメソッド呼び出し
        getRoomsInfo()

    }
    
    //ルームのデータ取得メソッド
    func getRoomsInfo(){
        
        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
        ref.child("Rooms").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            if(snap.exists()){
                let postsSnap = snap.value as! [String:AnyObject]
                //posts初期化
                self.posts = [Post]()
                for (_,ownerPost) in postsSnap{
                    //roomID取得
                    if let roomID = ownerPost["roomID"] as? String{
                        //posst初期化
                        self.posst = Post()
                        // ,で区切ってpathToImage,roomName,roomID,roomDeteil,roomAddmitNum,ownerUserID・・・取得
                        if let pathToImage = ownerPost["pathToImage"] as? String,
                            let roomName = ownerPost["roomName"] as? String,
                            let roomDetail = ownerPost["roomDetail"] as? String,
                            let roomAddmitNum = ownerPost["roomAddmitNum"] as? String,
                            let ownerUserID = ownerPost["ownerUserID"] as? String {
                            //posstの中に入れていく
                            self.posst.pathToImage = pathToImage
                            self.posst.roomID = roomID
                            self.posst.roomName = roomName
                            self.posst.roomDetail = roomDetail
                            self.posst.roomAddmitNum = roomAddmitNum
                            self.posst.ownerUserID = ownerUserID
                            
                            //Databaseのものと比較して住所が同じものだけを入れる
                            if (self.searchBar.text == ""){
                                self.posts.append(self.posst)
                                self.tableView.reloadData()
                            } else if (self.posst.roomName.contains(self.searchBar.text!) || self.posst.roomDetail.contains(self.searchBar.text!)){
                                self.posts.append(self.posst)
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //画面遷移
        performSegue(withIdentifier: "joinChat", sender: indexPath)
        
    }
    
    
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        let joinChatVC = segue.destination as! JoinChatViewController
        
        //RoomIDを渡したい
        joinChatVC.roomID = self.posst.roomID
        //RoomNameを渡したい
        joinChatVC.roomName = self.posst.roomName
        //PathToImageを渡したい profile画像用URL
        joinChatVC.pathToImage = self.posst.pathToImage
        //roomAddmitNumを渡したい 募集人数
        joinChatVC.roomAddmitNum = self.posst.roomAddmitNum
        //roomDetailを渡したい ルーム詳細
        joinChatVC.roomDetail = self.posst.roomDetail
        //roomDetailを渡したい ルーム詳細
        joinChatVC.ownerUserID = self.posst.ownerUserID

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Cell1というIdentifierをつける
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
        
        //ルームの写真
        //Tagに「1」を振っている
        let roomImageView = cell.contentView.viewWithTag(1) as! UIImageView
        //ownernameにタグを付ける
        let roomImageUrl = URL(string:self.posts[indexPath.row].pathToImage as String)!
        //Cashをとっている
        roomImageView.sd_setImage(with: roomImageUrl, completed: nil)
        
        //ルーム名
        //Tagに「2」を振っている
        let roomNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        roomNameLabel.text = self.posts[indexPath.row].roomName
        
        //ルーム詳細
        //Tagに「3」を振っている
        let roomDetailLabel = cell.contentView.viewWithTag(3) as! UILabel
        roomDetailLabel.text = self.posts[indexPath.row].roomDetail
        
        //ルーム人数
        //Tagに「4」を振っている
        let roomAddmitNumLabel = cell.contentView.viewWithTag(4) as! UILabel
        roomAddmitNumLabel.text = self.posts[indexPath.row].roomAddmitNum
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var num = self.posts.count
        if self.posts.count < 50 {
            // 取得件数が50件以下ならそのまま表示
            num = self.posts.count
        }else{
            // 取得件数が50件以上なら50件を表示
            num = 50
        }
        return num
    }
    
    // Cell の高さを60にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        //キーボードを閉じる。
        self.searchBar.endEditing(true)
        //検索結果配列を空にする。
        self.posts.removeAll()
        //ルームのデータを引っ張ってくるメソッド呼び出し
        getRoomsInfo()
    }
    
    //テキスト変更時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //辺作結果の配列をコピーする
        self.postsCopy = self.posts
        //検索結果配列を空にする。
        self.posts.removeAll()
        
        if(self.searchBar.text == "") {
            //検索文字列が空の場合はすべてを表示する。
            self.posts = self.postsCopy
        } else {
            //検索文字列を含むデータを検索結果配列に追加する。
            for data in self.postsCopy {
                if (data.roomName.contains(searchBar.text!) || data.roomDetail.contains(searchBar.text!)) {
                    self.posts.append(data)
                }
            }
        }
        //テーブルを再読み込みする。
        self.tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

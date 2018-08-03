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

        //デリゲート先を自分に設定する。
        searchBar.delegate = self

        //何も入力されていなくてもReturnキーを押せるようにする。
        searchBar.enablesReturnKeyAutomatically = false

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
            let postsSnap = snap.value as! [String:AnyObject]
            for (_,ownerPost) in postsSnap{
                //roomID取得
                if let roomID = ownerPost["roomID"] as? String{
                    //owner_posst初期化
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
            
            
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //画面遷移
        performSegue(withIdentifier: "joinChat", sender: indexPath)
        
    }
    
    
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        let privateChatVC = segue.destination as! PrivateChatViewController
        
        //RoomIDを渡したい
        privateChatVC.roomID = self.posst.roomID
        //RoomNameを渡したい
        privateChatVC.roomName = self.posst.roomName
        //PathToImageを渡したい profile画像用URL
        privateChatVC.pathToImage = self.posst.pathToImage
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Cell1というIdentifierをつける
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
        
        //ルームの写真
        //Tagに「0」を振っている
        let roomImageView = cell.contentView.viewWithTag(0) as! UIImageView
        //ownernameにタグを付ける
        let roomImageUrl = URL(string:self.posts[indexPath.row].pathToImage as String)!
        //Cashをとっている
        roomImageView.sd_setImage(with: roomImageUrl, completed: nil)
        
        //ルーム名
        //Tagに「1」を振っている
        let roomNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        roomNameLabel.text = self.posts[indexPath.row].roomName
        
        //ルーム詳細
        //Tagに「2」を振っている
        let roomDetailLabel = cell.contentView.viewWithTag(2) as! UILabel
        roomDetailLabel.text = self.posts[indexPath.row].roomDetail
        
        //ルーム人数
        //Tagに「3」を振っている
        let roomAddmitNumLabel = cell.contentView.viewWithTag(3) as! UILabel
        roomAddmitNumLabel.text = self.posts[indexPath.row].roomAddmitNum
        
        return tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
        
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
    
    // Cell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    
    @IBAction func profileEdit(_ sender: Any) {
        //画面遷移
        performSegue(withIdentifier: "profileEdit", sender: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        //ルームのデータを引っ張ってくるメソッド呼び出し
        getRoomsInfo()
        //キーボードを閉じる。
        self.searchBar.endEditing(true)
    }
    
    //テキスト変更時の呼び出しメソッド
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
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
        tableView.reloadData()
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

//
//  PrivateChatViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/06/11.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class PrivateChatViewController: JSQMessagesViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    var roomName:String!
    var roomID:String!
    var roomAddmitNum:String!
    var roomDetail:String!
    var backGroundImage:UIImage = UIImage()
    var memberNum:String!
    
    var iconPath: [String] = []
    
    var pathToImage:String!
    
    //吹き出しの部分の変数を定義
    var messages:[JSQMessage]! = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    var decodedImage = UIImage()
    var iconImage = UIImage()
    var aitenoImage:String!
    var uid = Auth.auth().currentUser?.uid

    var userInfoMap = LoginUserPost()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareNabiBar()
        self.getLoginUserInfo()
        self.prepareBackground()
        self.getInfo()
        self.chatStart()

    }
    
    //Postsの取得
    func getLoginUserInfo(){
        
        let ref = Database.database().reference()

        //Roomsの配下にあるデータを取得する
        ref.child("Users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            if(snap.exists()){
                let postsSnap = snap.value as! [String:AnyObject]
                for (_,userInfo) in postsSnap{
                    //userId取得
                    if let userID = userInfo["userID"] as? String{
                        //post初期化
                        self.userInfoMap = LoginUserPost()
                        if let pathToImage = userInfo["pathToImage"] as? String{
                            //posstの中に入れていく
                            self.userInfoMap.pathToImage = pathToImage
                            self.userInfoMap.userID = userID
                            if (self.userInfoMap.userID == self.uid)
                            {
                                do {
                                    let data = try Data(contentsOf: URL(string: self.userInfoMap.pathToImage)!)
                                    self.iconImage = UIImage(data: data)!
                                    self.pathToImage = self.userInfoMap.pathToImage
                                }catch{
                                    self.iconImage = UIImage(named: "background.jpg")!
                                }
                            }
                        }
                        
                    }
                }
            }
        })
    }

    //メッセージの位置を決める
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath as IndexPath) as? JSQMessagesCollectionViewCell
        
        //メッセージ色の設定
        if messages[indexPath.row].senderId == senderId{
            cell?.textView.textColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)
        }else{
            cell?.textView?.textColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)
        }
        return cell!
    }
    
    //参照するメッセージを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return self.messages?[indexPath.item]
    }
    
    //背景を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = self.messages?[indexPath.row]
        if message?.senderId == senderId{
            return self.outgoingBubble
        }else{
            return self.incomingBubble
        }
    }
    
    //アバターを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = self.messages?[indexPath.row]
        if message?.senderId == senderId{
            self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: self.iconImage, diameter: 64)
            return self.outgoingAvatar
        }else{
            let url = URL(string: self.iconPath[indexPath.row])
            let data = try? Data(contentsOf: url!)
            let image = UIImage(data: data!)
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder:image, diameter: 64)
            
            return self.incomingAvatar
        }
    }
    
    //メッセージの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.messages.count
    }
    //吹き出しの設定をする
    func chatStart(){
        
        inputToolbar.contentView!.leftBarButtonItem = nil
        automaticallyAdjustsScrollViewInsets = true
        self.senderId = uid
        self.senderDisplayName = "自分"
        
        //0から4までの値を取得する
        let random = arc4random() % 5
        //print(random)
        self.decodedImage = UIImage(named: "\(random).png")!
        
        //let imageData2 :NSData = try! NSData(contentsOf: URL(string: self.pathToImage)!,options: NSData.ReadingOptions.mappedIfSafe)


        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        //吹き出しの色の設定
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.white)
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 255/255, green: 233/255, blue: 51/255, alpha: 1.0))
        
        //self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder:self.decodedImage, diameter: 64)
        
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: self.iconImage, diameter: 64)
        //メッセージの配列の初期化
        self.messages = []
    }
    //メッセージをFirebaseに入れる
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if(text == nil || text == ""){
            return
        }
        
        let rootRef = Database.database().reference(fromURL: "https://shallwe-28db7.firebaseio.com/").child("message").child(self.roomID)
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let post:Dictionary<String,Any>? = ["from":senderId,"name":senderDisplayName,"text":text,"timestamp":timestamp,"profileImage":self.pathToImage]
        let postRef = rootRef.childByAutoId()
        postRef.setValue(post)
        self.inputToolbar.contentView.textView.text = ""
    }
    //メッセージをFirebaseから取ってくる
    func getInfo(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let firebase = Database.database().reference(fromURL: "https://shallwe-28db7.firebaseio.com/").child("message").child(self.roomID)
        firebase.observe(.childAdded, with:{
            (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                let snapshotValue = snapshot.value as! NSDictionary
                snapshotValue.setValuesForKeys(dictionary)
                let text = snapshotValue["text"] as! String
                let senderId = snapshotValue["from"] as! String
                let name = snapshotValue["name"] as! String
                let icon = snapshotValue["profileImage"] as! String
                let message = JSQMessage(senderId:senderId,displayName: name,text: text)
                self.messages?.append(message!)
                self.iconPath.append(icon)
                self.finishReceivingMessage()
            }
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        let roomDetailVC = segue.destination as! RoomDetailViewController
        
        //RoomIDを渡したい
        roomDetailVC.roomID = self.roomID
        //RoomNameを渡したい
        roomDetailVC.roomName = self.roomName
        //PathToImageを渡したい profile画像用URL
        roomDetailVC.pathToImage = self.pathToImage
        //roomAddmitNumを渡したい 募集人数
        roomDetailVC.roomAddmitNum = self.roomAddmitNum
        //memberNumを渡したい 募集人数
        roomDetailVC.memberNum = self.memberNum
        //roomDetailを渡したい ルーム詳細
        roomDetailVC.roomDetail = self.roomDetail
        //roomDetailを渡したい ルーム詳細
        roomDetailVC.ownerUserID = self.uid!
        
    }
    //NabigationBatの設定
    func prepareNabiBar(){
        // navigationvarの準備
        self.navigationItem.title = self.roomName
        let rightBarButtonItem :UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info_Icon.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target:self, action: #selector(PrivateChatViewController.rightButtonTapped(_:)))
        rightBarButtonItem.tintColor = UIColor.white
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }
    // 背景の設定
    func prepareBackground(){
        //初期画像の設定
        backGroundImage = UIImage(named: "backGroundImageForChatRoom.jpg")!
        //背景画像を設定する
        if let imageData = UserDefaults.standard.object(forKey: "backGroundImage")  {
            if (imageData as AnyObject).length != 0{
                backGroundImage = UIImage(data: imageData as! Data)!
            }
        }
        self.collectionView.backgroundColor = UIColor.clear
        
        let backImageView = UIImageView()
        backImageView.image = backGroundImage
        backImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        self.view.insertSubview(backImageView, at: 0)
    }

    @objc func rightButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "roomDetail", sender: nil)
    }

}

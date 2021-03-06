//
//  ChatViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/06/09.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {

    var decodedImage = UIImage()
    var iconImage = UIImage()

    var roomName = String()
    var address = String()
    var pathToImage = String()
    
    var messages:[JSQMessage]! = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    var backGroundImage = UIImage()
    var aitenoImage:String!
    var uid = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //左から右へスワイプしたときのジェスチャーリコグナイザーをcollectionviewに追加
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(sender:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        if let imageData = UserDefaults.standard.object(forKey: "backGroundImage"){
            if (imageData as AnyObject).length != 0{
                backGroundImage = UIImage(data: imageData as! Data)!
            }else{
                backGroundImage = UIImage(named: "background.jpg")!
            }
        }
        
        self.collectionView.backgroundColor = UIColor.clear
        
        let backImageView = UIImageView()
        backImageView.image = backGroundImage
        backImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.collectionView.insertSubview(backImageView, at: 0)
        //chatViewから戻るボタンを生成する
        let topView:UIView = UIView()
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50)
        topView.backgroundColor = UIColor.red
        self.view.addSubview(topView)

        // ブラーエフェクトを生成（ここでエフェクトスタイルを指定する）
        let blurEffect = UIBlurEffect(style: .dark)
        // ブラーエフェクトからエフェクトビューを生成
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        // エフェクトビューのサイズを指定（オリジナル画像と同じサイズにする）
        visualEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        //ラベル生成
        let label = UILabel()
        //フレームのサイズを指定
        label.frame = CGRect(x: 0, y: self.view.frame.size.height/2, width: self.view.frame.size.width, height: 100)
        //ルームネームを代入して、visualEffectViewに入れる
        label.text = roomName
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        visualEffectView.contentView.addSubview(label)
        self.collectionView.addSubview(visualEffectView)
        //２秒後に実行するメソッド
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // ブラービューを消す
            visualEffectView.removeFromSuperview()
        }
        
        self.getInfo()
        self.chatStart()
    }

    //スワイプしたときに呼ばれるメソッド
    @objc final func didSwipe(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .right {
            print("Right")
            
            self.dismiss(animated: true, completion: nil)
        }
        else if sender.direction == .left {
            print("Left")
        }
    }
    //メッセージの位置を決める
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath as IndexPath) as? JSQMessagesCollectionViewCell
        
        if messages[indexPath.row].senderId == senderId{
            cell?.textView.textColor = UIColor.white
        }else{
            cell?.textView?.textColor = UIColor.darkGray
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
            return self.outgoingAvatar
        }else{
            return self.incomingAvatar
        }
    }
    
    //メッセージの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.messages.count
    }

    func chatStart(){
        //写真や動画を使えなくする
        inputToolbar.contentView!.leftBarButtonItem = nil
        //自動でscrollViewを調整
        automaticallyAdjustsScrollViewInsets = true
        //idとdisplaynameを準備
        self.senderId = uid
        self.senderDisplayName = "自分"
        
        //0から4までの乱数の値を取得する
        let random = arc4random() % 5
        print(random)
        //乱数でimegeをデコード
        decodedImage = UIImage(named: "\(random).png")!
        //渡ってきたiconのイメージ画像をデータ型にしてiconImageに入れる
        let imageData2 :NSData = try! NSData(contentsOf: URL(string: pathToImage)!,options: NSData.ReadingOptions.mappedIfSafe)
        iconImage = UIImage(data:imageData2 as Data)!
        
        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        //相手から来たメッセージはデコードイメージ
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder:decodedImage, diameter: 64)
        //自分のメッセージはiconイメージを使う
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: iconImage, diameter: 64)
        //メッセージの配列の初期化
        self.messages = []
    }
    
    //メッセージをFirebaseに入れる
    //sendボタンを押したときに動く
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        //送り先のURL
        let rootRef = Database.database().reference(fromURL: "https://shallwe-28db7.firebaseio.com/").child("message").child(address).child(roomName)
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        //送る内容
        let post:Dictionary<String,Any>? = ["from":senderId,"name":senderDisplayName,"text":text,"timestamp":timestamp,"profileImage":pathToImage]
        
        let postRef = rootRef.childByAutoId()
        //setValueする
        postRef.setValue(post)
        
        self.inputToolbar.contentView.textView.text = ""
    }
    //メッセージをとってくる
    func getInfo(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let firebase = Database.database().reference(fromURL: "https://shallwe-28db7.firebaseio.com/").child("message").child(address).child(roomName)
        firebase.observe(.childAdded, with:{
            (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                let snapshotValue = snapshot.value as! NSDictionary
                snapshotValue.setValuesForKeys(dictionary)
                let text = snapshotValue["text"] as! String
                let senderId = snapshotValue["from"] as! String
                let name = snapshotValue["name"] as! String
                self.aitenoImage = snapshotValue["profileImage"] as! String
                let message = JSQMessage(senderId:senderId,displayName: name,text: text)
                self.messages?.append(message!)
                
                self.finishReceivingMessage()
            }
        })
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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

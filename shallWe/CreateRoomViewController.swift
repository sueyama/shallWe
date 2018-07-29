//
//  CreateRoomViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/06/08.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import SDWebImage

class CreateRoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!

    //ログインユーザの情報のパラメータ
    @IBOutlet var topLoginUserImage: UIImageView!
    @IBOutlet var topLoginUserName: UITextField!
    @IBOutlet var topLoginProfileDetail: UITextView!

    var userInfo = [LoginUserPost]()
    var userInfoMap = LoginUserPost()

    var data:Data = Data()
    var imageString:String!

    override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    //ログインユーザのデータを引っ張ってくるメソッド呼び出し
    getLoginUserInfo()

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
                    let userName = userInfo["userName"] as? String,
                    let profileDetail = userInfo["profileDetail"] as? String
                {
                    //posstの中に入れていく
                    self.userInfoMap.pathToImage = pathToImage
                    self.userInfoMap.userID = userID
                    self.userInfoMap.userName = userName
                    self.userInfoMap.profileDetail = profileDetail
                    
                    if (self.userInfoMap.userID == self.uid)
                    {
                        //ログインユーザの情報設定
                        self.topLoginUserImage.sd_setImage(with: self.userInfoMap.pathToImage as! URL, completed: nil)
                        if(self.userInfoMap.userName != "未設定"){
                            self.topLoginUserName.text = self.userInfoMap.userName
                        }
                        if(self.userInfoMap.profileDetail != "未設定"){
                            self.topLoginProfileDetail.text = self.userInfoMap.profileDetail
                        }
                    }
                }
                
            }
        }
        
        
    })
    }

    @IBAction func setBackGroundView(_ sender: Any) {
    showAlertViewController()
    }

    //カメラまたはアルバム使用の際にアラートを出す
    func showAlertViewController(){
    //アラートビューを生成
    let alertController = UIAlertController(title: "選択してください。", message: "チャットの背景画像を変更します。", preferredStyle: .actionSheet)
    //カメラボタンを生成
    let cameraButton:UIAlertAction = UIAlertAction(title: "カメラから", style: UIAlertActionStyle.default,handler: { (action:UIAlertAction!) in
        //ボタン押下時の処理
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
            cameraPicker.allowsEditing = true
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        
    })
    //アルバムボタンの生成
    let albumButton:UIAlertAction = UIAlertAction(title: "アルバムから", style: UIAlertActionStyle.default,handler: { (action:UIAlertAction!) in
        //
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
        // アルバムが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        
    })

    let cancelButton:UIAlertAction = UIAlertAction(title: " キャンセル", style: UIAlertActionStyle.cancel,handler: { (action:UIAlertAction!) in
        
        //キャンセル時の処理(何もしない)
        
    })
    //アラートビューコントローラーにボタンをセット
    alertController.addAction(cameraButton)
    alertController.addAction(albumButton)
    alertController.addAction(cancelButton)
    //アラートビューコントローラー表示
    present(alertController, animated: true, completion: nil)
    }

    //選択した写真をプロフィールに設置する(delegateメソッド)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    //プロフィールの写真に設置する
    self.topLoginUserImage = info[UIImagePickerControllerOriginalImage] as? UIImageView
    //カメラ画面(アルバム画面)を閉じる処理
    picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func profileHzn(_ sender: Any) {
    //FireBaseのDatabaseを宣言
    let ref = Database.database().reference()
    //StorageのURLを取得
    let storage = Storage.storage().reference(forURL: "gs://shallwe-28db7.appspot.com/")
    let key = ref.child("Users").childByAutoId().key
    let imageRef = storage.child("Users").child(uid!).child("\(key).png")

    self.data = UIImageJPEGRepresentation(UIImage(named: "profileImage.png")!, 0.6)!

    let uploadTask = imageRef.putData(self.data, metadata: nil) { (metaData, error) in
        
        if error != nil {
            
            AppDelegate.instance().dismissActivityIndicator()
            return
        }
        //URLはストレージのURL(Firebase上のURLのみを入れる)
        imageRef.downloadURL(completion: { (url, error) in
            if url != nil {
                //feedの中に、キー値と値のマップを入れている
                //userId,profileImage,postId,住所全体,
                let feed = ["userID":self.uid!,"pathToImage":self.topLoginUserImage!,"userName":self.topLoginUserName,"profileDetail":self.topLoginProfileDetail] as [String:Any]
                
                //feedにkey値を付ける
                let postFeed = ["\(key)":feed]
                self.imageString = self.profileImage.absoluteString
                //DatabaseのRoomsの下にすべて入れる
                ref.child("Users").updateChildValues(postFeed)
                //indicatorを止める
                AppDelegate.instance().dismissActivityIndicator()
                //TOP画面へ遷移
                print("保存しました")
                self.dismiss(animated: true, completion: nil)
                
            }
            
        })
        
    }

    uploadTask.resume()

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

//
//  ProfileEditViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/07/27.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    //ログインユーザの情報のパラメータ
    @IBOutlet var topLoginUserImage: UIImageView!
    @IBOutlet var topLoginUserName: UITextField!
    @IBOutlet weak var topLoginProfileDetail: UITextView!
    @IBOutlet weak var noImageArea: UIView!
    //保存ボタン
    @IBOutlet weak var saveButton: UIButton!
    //閉じるボタン
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var statusBar: UIView!
    
    //右上の閉じるボタン押下時の挙動
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func setBackGroundView(_ sender: Any) {
        showAlertViewController()
    }
    @IBAction func profileHzn(_ sender: Any) {
        saveProfile()
    }

    //TopViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage = String();

    var userInfo = [LoginUserPost]()
    var userInfoMap = LoginUserPost()
    var data:Data = Data()
    var imageString:String!
    
    //テキストビューの表示領域
    var originalFrame:CGRect?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //テキストビューの元のframeを取得する（テキストフィールド可変設定用）
        originalFrame = topLoginProfileDetail.frame

        //ログインユーザのデータを引っ張ってくるメソッド呼び出し
        getLoginUserInfo()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.topLoginUserName.delegate = self
        
        editUI()
        //通知センターのオブジェクトを作成
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(ProfileEditViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notification.addObserver(self, selector: #selector(ProfileEditViewController.keyboardChangeFrame(_:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        notification.addObserver(self, selector: #selector(ProfileEditViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

    }
    //キーボード表示時の挙動
    @objc func keyboardDidShow(_ notification:Notification){
        
    }
    //キーボード変更時の挙動
    @objc func keyboardChangeFrame(_ notification:Notification){
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as!  NSValue).cgRectValue
        
        var textViewFrame = topLoginProfileDetail.frame

        textViewFrame.size.height = keyboardFrame.minY - textViewFrame.minY - 70
        topLoginProfileDetail.frame = textViewFrame
    }
    //キーボード非表示時の挙動
    @objc func keyboardDidHide(_ notification:Notification){
        topLoginProfileDetail.frame = originalFrame!
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
                        let profileDetail = userInfo["profileDetail"] as? String, let postID = userInfo["postID"] as? String
                    {
                        //posstの中に入れていく
                        self.userInfoMap.pathToImage = pathToImage
                        self.userInfoMap.userID = userID
                        self.userInfoMap.userName = userName
                        self.userInfoMap.profileDetail = profileDetail
                        self.userInfoMap.postID = postID
                        
                        if (self.userInfoMap.userID == self.uid)
                        {
                            //ログインユーザの情報設定
                            self.topLoginUserImage.sd_setImage(with: URL(string:  self.userInfoMap.pathToImage), completed: nil)
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
        self.topLoginUserImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //カメラ画面(アルバム画面)を閉じる処理
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func saveProfile(){
        //FireBaseのDatabaseを宣言
        let ref = Database.database().reference()
        //StorageのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://shallwe-28db7.appspot.com/")
        let key = ref.child("Users").childByAutoId().key
        let imageRef = storage.child("Users").child(uid!).child("\(key).png")
        
        var imageData:NSData = NSData()
        
        if let image = self.topLoginUserImage.image{
            imageData = UIImageJPEGRepresentation(image, 0.5)! as NSData
        }

        let uploadTask = imageRef.putData(imageData as Data, metadata: nil) { (metaData, error) in
            
            if error != nil {
                
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            //URLはストレージのURL(Firebase上のURLのみを入れる)
            imageRef.downloadURL(completion: { (url, error) in
                if url != nil {
                    //feedの中に、キー値と値のマップを入れている
                    //userId,profileImage,postId,住所全体,
                    let feed = ["userID":self.uid!,"pathToImage":url?.absoluteString,"userName":self.topLoginUserName.text,"profileDetail":self.topLoginProfileDetail.text] as [String:Any]
                    
                    //feedにkey値を付ける
                    let postFeed = [self.userInfoMap.postID:feed]
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
    //見た目の設定
    func editUI(){
        //各種パーツの色設定
        statusBar.backgroundColor = UIColor(red: 50/255, green: 58/255, blue: 67/255, alpha: 1.0) // dark black
        closeButton.tintColor = UIColor.white
        saveButton.backgroundColor =  UIColor(red: 50/255, green: 58/255, blue: 67/255, alpha: 1.0) // dark black
        saveButton.layer.borderWidth = 0 // 枠線の幅
        saveButton.layer.borderColor = UIColor.red.cgColor // 枠線の色
        saveButton.layer.cornerRadius = 18.0 // 角丸のサイズ
        saveButton.setTitleColor(UIColor(red: 255/255, green: 233/255, blue: 51/255, alpha: 1.0),for: UIControlState.normal) // タイトルの色
        
        //プロフィール入力欄の見た目の設定
        topLoginProfileDetail.layer.borderWidth = 1 // 枠線の幅
        topLoginProfileDetail.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0).cgColor // 枠線の色
        topLoginProfileDetail.layer.cornerRadius = 8.0 // 角丸のサイズ
        //noImageAreaの枠線設定
        noImageArea.layer.borderWidth = 1
        noImageArea.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255,alpha: 1.0).cgColor

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

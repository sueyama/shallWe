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
import Photos

class CreateRoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate{
        
    var ownerUserID = Auth.auth().currentUser?.uid
    var roomId:String!
    var profileImage:URL!
    //ルーム情報のパラメータ
    @IBOutlet var roomImage: UIImageView!
    @IBOutlet var roomName: UITextField!
    @IBOutlet var roomAddmitNum: UITextField!
    @IBOutlet var roomDetail: UITextView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var noImageArea: UIView!
    
    
    @IBAction func tapView(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func profileHzn(_ sender: Any) {
        createRoom()
    }

    @IBAction func setBackGroundView(_ sender: Any) {
        showAlertViewController()
    }

    var roomInfo = [Post]()
    var roomInfoMap = Post()
    var data:Data = Data()
    
    //テキストビューの表示領域
    var originalFrame:CGRect?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editUI()
        //テキストビューの元のframeを取得する（テキストフィールド可変設定用）
        originalFrame = roomDetail.frame

        self.roomName.delegate = self
        self.roomAddmitNum.delegate = self
        //roomAddmitNumを数値入力のみにする
        self.roomAddmitNum.keyboardType = UIKeyboardType.numberPad

        // アルバムの使用許可を取る
        libraryRequestAuthorization()
        
        //通知センターのオブジェクトを作成
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(CreateRoomViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notification.addObserver(self, selector: #selector(CreateRoomViewController.keyboardChangeFrame(_:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        notification.addObserver(self, selector: #selector(CreateRoomViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

    }

    //キーボード表示時の挙動
    @objc func keyboardDidShow(_ notification:Notification){
        
    }
    //キーボード変更時の挙動
    @objc func keyboardChangeFrame(_ notification:Notification){
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as!  NSValue).cgRectValue
        
        var textViewFrame = roomDetail.frame
        
        textViewFrame.size.height = keyboardFrame.minY - textViewFrame.minY - 70
        roomDetail.frame = textViewFrame
    }
    //キーボード非表示時の挙動
    @objc func keyboardDidHide(_ notification:Notification){
        roomDetail.frame = originalFrame!
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
        self.roomImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        //カメラ画面(アルバム画面)を閉じる処理
        picker.dismiss(animated: true, completion: nil)
    }


    // カメラロールへのアクセス許可
    fileprivate func libraryRequestAuthorization() {
        PHPhotoLibrary.requestAuthorization { (status) in
            
            switch(status){
                
            case .authorized:
                break
                
            case .denied:
                break
                
            case .notDetermined:
                break
            case .restricted:
                break
            }
            
        }
    }


    func createRoom(){
        //FireBaseのDatabaseを宣言
        let ref = Database.database().reference()
        //StorageのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://shallwe-28db7.appspot.com/")
        let key = ref.child("Rooms").childByAutoId().key
        let imageRef = storage.child("Rooms").child(ownerUserID!).child("\(key).png")
        
        var imageData:NSData = NSData()
        
        if let image = self.roomImage.image{
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
                    //roomId,roomName,roomDetail,roomAddmitNum,ownerUserID,住所全体,
                    let feed = ["roomID":key,"roomName":self.roomName.text,"roomDetail":self.roomDetail.text,"roomAddmitNum":self.roomAddmitNum.text,"memberNum":"0","pathToImage":url?.absoluteString,"ownerUserID":self.ownerUserID!] as [String:Any]
        
                    //feedにkey値を付ける
                    let postFeed = ["\(key)":feed]
                    //DatabaseのRoomsの下にすべて入れる
                    ref.child("Rooms").updateChildValues(postFeed)
                    //indicatorを止める
                    AppDelegate.instance().dismissActivityIndicator()
                    //TOP画面へ遷移
                    print("ルームの作成が完了しました")
                    //TOPnのタブの
                    self.tabBarController?.selectedIndex = 0
                }
                
            })
            
        }
        
        uploadTask.resume()


    }
    //見た目の設定
    func editUI(){
        //保存ボタンの色設定
        createButton.backgroundColor =  UIColor(red: 50/255, green: 58/255, blue: 67/255, alpha: 1.0) // dark black
        createButton.layer.borderWidth = 0 // 枠線の幅
        createButton.layer.borderColor = UIColor.red.cgColor // 枠線の色
        createButton.layer.cornerRadius = 18.0 // 角丸のサイズ
        createButton.setTitleColor(UIColor(red: 255/255, green: 233/255, blue: 51/255, alpha: 1.0),for: UIControlState.normal) // タイトルの色
        
        //プロフィール入力欄の見た目の設定
        roomDetail.layer.borderWidth = 1 // 枠線の幅
        roomDetail.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0).cgColor // 枠線の色
        roomDetail.layer.cornerRadius = 8.0 // 角丸のサイズ
        
        //noImageAreaの枠線設定
        noImageArea.layer.borderWidth = 1
        noImageArea.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255,alpha: 1.0).cgColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

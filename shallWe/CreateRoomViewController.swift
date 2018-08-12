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

class CreateRoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
    var ownerUserID = Auth.auth().currentUser?.uid
    var roomId:String!

    //ルーム情報のパラメータ
    @IBOutlet var roomImage: UIImageView!
    @IBOutlet var roomName: UITextField!
    @IBOutlet var roomDetail: UITextView!
    @IBOutlet var roomAddmitNum: UITextField!
    
    var roomInfo = [Post]()
    var roomInfoMap = Post()

    var data:Data = Data()

    override func viewDidLoad() {
    super.viewDidLoad()
        // アルバムの使用許可を取る
        libraryRequestAuthorization()

    // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    //Postsの取得
    func getLoginUserInfo(){

        let ref = Database.database().reference()
        //Roomsの配下にあるデータを取得する
        ref.child("Rooms").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            let postsSnap = snap.value as! [String:AnyObject]
            for (_,roomInfo) in postsSnap{
                //userId取得
                if let ownerUserID = roomInfo["ownerUserID"] as? String{
                    //post初期化
                    self.roomInfoMap = Post()
                    // ,で区切ってpathToImage,userID,userName・・・取得
                    if let pathToImage = roomInfo["pathToImage"] as? String,
                        let userName = roomInfo["userName"] as? String,
                        let profileDetail = roomInfo["profileDetail"] as? String
                    {
                        //posstの中に入れていく
                        self.roomInfoMap.pathToImage = pathToImage
                        self.roomInfoMap.ownerUserID = self.ownerUserID
                        
                        if (self.roomInfoMap.ownerUserID == self.ownerUserID)
                        {
                            
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
        self.roomImage = info[UIImagePickerControllerOriginalImage] as? UIImageView
        //カメラ画面(アルバム画面)を閉じる処理
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func profileHzn(_ sender: Any) {
        //FireBaseのDatabaseを宣言
        let ref = Database.database().reference()
        //StorageのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://shallwe-28db7.appspot.com/")
        let key = ref.child("Rooms").childByAutoId().key
        let imageRef = storage.child("Rooms").child(ownerUserID!).child("\(key).png")

        self.data = UIImageJPEGRepresentation(UIImage(named: "roomImage.png")!, 0.6)!

        let uploadTask = imageRef.putData(self.data, metadata: nil) { (metaData, error) in
            
            if error != nil {
                
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            //URLはストレージのURL(Firebase上のURLのみを入れる)
            imageRef.downloadURL(completion: { (url, error) in
                if url != nil {
                    //feedの中に、キー値と値のマップを入れている
                    //roomId,roomName,roomDetail,roomAddmitNum,ownerUserID,住所全体,
                    let feed = ["roomID":(self.ownerUserID! + self.roomName.text! + self.roomAddmitNum.text!),"roomName":self.roomName.text!,"roomDetail":self.roomDetail,"roomAddmitNum":self.roomAddmitNum.text!,"pathToImage":self.roomImage,"ownerUserID":self.ownerUserID] as [String:Any]

                    //feedにkey値を付ける
                    let postFeed = ["\(key)":feed]
                    //DatabaseのRoomsの下にすべて入れる
                    ref.child("Rooms").updateChildValues(postFeed)
                    //indicatorを止める
                    AppDelegate.instance().dismissActivityIndicator()
                    //TOP画面へ遷移
                    print("ルームの作成が完了しました")
                    
                    
                }
                
            })
        
        }

        uploadTask.resume()

    }

//    @IBAction func back(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }

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

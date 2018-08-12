//
//  LoginViewController.swift
//  
//
//  Created by 上山　俊佑 on 2018/05/31.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn
import CoreLocation

class LoginViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate,CLLocationManagerDelegate {

    //googleのimagephotoのURL用
    var profileImage:URL!
    //位置情報取得用
    var locationManager:CLLocationManager!
    //uid用
    var uid = Auth.auth().currentUser?.uid
    //userName用
    var profileUserName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CLLocation初期化、delegate作成、位置情報取得開始
        catchLocationData()

        // google サインインのボタン作成・大きさ設定など
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 20, y: 250, width: self.view.frame.size.width-40, height: 60)
        view.addSubview(googleButton)
        // uiDelegate,delegate設定、クライアントIDの取得
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    //画面遷移する際に呼ばれる関数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //遷移の際にUIDとprofileImageをselectViewControllerに渡す
        let selectVC = segue.destination as! TabBarController
        selectVC.uid = uid
        selectVC.profileImage = self.profileImage! as NSURL
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //サインインが失敗したとき
        if let err = error {
            print("エラーです。",err)
            return
        }
        //サインインが成功したとき
        print("成功しました！")
        //loginに0をセットすることで最初に、次回開いたときに勝手にログインされる
        UserDefaults.standard.set(0, forKey: "login")
        //idToken,accessTokenを取得する
        guard let idToken = user.authentication.idToken else {
            return
        }
        guard let accessToken = user.authentication.accessToken else{
            return
        }
        //idToken,accessTokenからcredential取得
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        //credentialからAuth認証をする
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (user,error) in
            if let err = error{
                print("エラー",err)
                return
            }
            //auth認証したgoogleアカウントに設定してある画像取得
            let imageUrl = signIn.currentUser.profile.imageURL(withDimension: 100)
            self.profileImage = imageUrl

            //firebaseに飛ばす
            self.postMyProfile()
            //nextに画面遷移
            self.performSegue(withIdentifier: "next", sender: nil)
            
        })
    }

    func postMyProfile(){
        //signinをしている間プロフィール画像を飛ばすindicatorを回している
        AppDelegate.instance().showIndicator()
        
        //uid取得
        uid = Auth.auth().currentUser?.uid
        //firebaseのdatabaseの定義
        let ref = Database.database().reference(fromURL: "https://shallwe-28db7.firebaseio.com/")
        //stragefileのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://shallwe-28db7.appspot.com/")
        //usersという階層を作成
        let key = ref.child("Users").childByAutoId().key
        //stragefileに入ってくる画像のURLの在り処
        let imageRef = storage.child("Users").child(uid!).child("\(key).jpg")

        var imageData:NSData = NSData()

        if let image = self.profileImage{
            imageData = try! NSData(contentsOf: image)
        }

        let uploadTask = imageRef.putData(imageData as Data)
        uploadTask.resume()
        //userId,postIdをkeyとしてpostimageをfeedという変数に設定
        let feed = ["userID":self.uid!,"pathToImage":self.profileImage.absoluteString,"postID":key,"userName":"未設定","profileDetail":"未設定"] as [String:Any]
        let postFeed = ["\(key)":feed]
        //Users以下のdatabaseのアップデートをする
        ref.child("Users").updateChildValues(postFeed)
        AppDelegate.instance().dismissActivityIndicator()

        //アップロードしたimagefileを置く
//        let uploadTask = imageRef.putData(imageData as Data, metadata: nil,completion:{ (metaData, error) in
//            if error != nil {
//                //エラーが出たらindevatorをストップさせる
//                AppDelegate.instance().dismissActivityIndicator()
//                return
//            }
//
//            imageRef.downloadURL(completion: { (url, error) in
//                if url != nil {
//                    //userId,postIdをkeyとしてpostimageをfeedという変数に設定
//                    let feed = ["userID":self.uid!,"pathToImage":self.profileImage.absoluteString,"postID":key,"userName":"未設定","profileDetail":"未設定"] as [String:Any]
//                    let postFeed = ["\(key)":feed]
//                    //Users以下のdatabaseのアップデートをする
//                    ref.child("Users").updateChildValues(postFeed)
//                    //Indicatorをストップする
//                    AppDelegate.instance().dismissActivityIndicator()
//                }
//            })
//        })
//        uploadTask.resume()
    }
    
    func catchLocationData(){
        //もしlocationが使えるならCLLocation初期化、delegate作成、位置情報取得開始する
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
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

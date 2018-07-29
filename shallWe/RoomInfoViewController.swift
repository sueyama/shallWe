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

class RoomInfoViewController: UIViewController,CLLocationManagerDelegate {
    var posts = [Post]()
    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
    //住所取得用
    var locationManager: CLLocationManager!
    //緯度経度
    @IBOutlet var idoLabel: UILabel!
    @IBOutlet var keidoLabel: UILabel!
    //住所が入る変数
    var country:String = String()
    var administrativeArea:String = String()
    var subAdministrativeArea:String = String()
    var locality:String = String()
    var subLocality:String = String()
    var thoroughfare:String = String()
    var subThoroughfare:String = String()
    var address:String = String()
    
    var data:Data = Data()
    var imageString:String!
    
    
    //部屋の名前を入れるところ
    @IBOutlet var inputRoomNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //viewDidLoadは一回しか実行されないがviewWillAppearは画面が表示されるたびに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        catchLocationData()
    }
    
    //現在地情報の許可に関するアラート
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    //緯度経度情報を取得して緯度経度から住所へ変換
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        self.idoLabel.text = "".appendingFormat("%.4f", newLocation.coordinate.latitude)
        self.keidoLabel.text = "".appendingFormat("%.4f", newLocation.coordinate.longitude)
        self.reverseGeocode(latitude: Double(idoLabel.text!)!, longitude: Double(keidoLabel.text!)!)
    }
    
    //現在地取得
    func catchLocationData(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    // 逆ジオコーディング処理(緯度・経度を住所に変換)
    func reverseGeocode(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemark, error) -> Void in
            let placeMark = placemark?.first
            if let country = placeMark?.country {
                
                
                print("\(country)")
                
                self.country = country
            }
            if let administrativeArea = placeMark?.administrativeArea {
                print("\(administrativeArea)")
                
                self.administrativeArea = administrativeArea
            }
            if let subAdministrativeArea = placeMark?.subAdministrativeArea {
                print("\(subAdministrativeArea)")
                
                self.subAdministrativeArea = subAdministrativeArea
                
            }
            if let locality = placeMark?.locality {
                print("\(locality)")
                
                self.locality = locality
            }
            if let subLocality = placeMark?.subLocality {
                print("\(subLocality)")
                
                self.subLocality = subLocality
            }
            if let thoroughfare = placeMark?.thoroughfare {
                print("\(thoroughfare)")
                
                self.thoroughfare = thoroughfare
            }
            if let subThoroughfare = placeMark?.subThoroughfare {
                print("\(subThoroughfare)")
                
                self.subThoroughfare = subThoroughfare
            }
            
            self.address = self.country + self.administrativeArea + self.subAdministrativeArea
                + self.locality + self.subLocality
            
        })
    }
    
    //次の画面に行くときに実行される
    func postRoom(){
        //indicatorを回す
        AppDelegate.instance().showIndicator()
        //緯度経度から住所へ変更
        reverseGeocode(latitude: Double(idoLabel.text!)!, longitude: Double(keidoLabel.text!)!)
        
        //FireBaseのDatabaseを宣言
        let ref = Database.database().reference()
        //StorageのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://shallwe-28db7.appspot.com/")
        let key = ref.child("Rooms").childByAutoId().key
        let imageRef = storage.child("Rooms").child(uid!).child("\(key).png")
        //
        self.data = UIImageJPEGRepresentation(UIImage(named: "ownerImage.png")!, 0.6)!
        
        let uploadTask = imageRef.putData(self.data, metadata: nil) { (metaData, error) in
            
            if error != nil {
                
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            //URLはストレージのURL(Firebase上のURLのみを入れる)
            imageRef.downloadURL(completion: { (url, error) in
                if url != nil {
                    //feedの中に、キー値と値のマップを入れている
                    //userId,profileImage,緯度,軽度,postId,住所全体,
                    let feed = ["userID":self.uid!,"pathToImage":self.profileImage.absoluteString!,"ido":self.idoLabel.text!,"keido":self.keidoLabel.text!,"roomName":self.inputRoomNameTextField.text!,"postID":key,"country":self.country,"administrativeArea":self.administrativeArea,"subAdministrativeArea":self.subAdministrativeArea,"locality":self.locality,"subLocality":self.subLocality,"thoroughfare":self.thoroughfare,"subThoroughfare":self.subThoroughfare] as [String:Any]
                    
                    //feedにkey値を付ける
                    let postFeed = ["\(key)":feed]
                    self.imageString = self.profileImage.absoluteString
                    //DatabaseのRoomsの下にすべて入れる
                    ref.child("Rooms").updateChildValues(postFeed)
                    //indicatorを止める
                    AppDelegate.instance().dismissActivityIndicator()
                    //次の画面へ遷移
                    self.performSegue(withIdentifier: "room", sender: nil)
                    
                }
                
            })
            
        }
        
        uploadTask.resume()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatVC = segue.destination as! ChatViewController
        chatVC.roomName = inputRoomNameTextField.text!
        chatVC.address =  self.address
        chatVC.pathToImage = self.profileImage.absoluteString!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputRoomNameTextField.resignFirstResponder()
    }
    
    //チャットルームに行く
    @IBAction func toTheChatRoom(_ sender: Any) {
        postRoom()
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

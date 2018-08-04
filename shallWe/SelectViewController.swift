//
//  SelectViewController.swift
//  shallWe
//
//  Created by 上山　俊佑 on 2018/06/02.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SelectViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //LoginViewControllerからパラメーターを取得する
    var uid = Auth.auth().currentUser?.uid
    var profileImage:NSURL!
    var locationManager: CLLocationManager!
    //緯度経度(Label)用のパラメータ
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        //veiwDidLoadは一回しか呼ばれないのでこれで現在地取得関数を呼ぶ
        super.viewWillAppear(animated)
        
        catchLocationData()
        
    }
    
    func catchLocationData(){
        //現在地を取得する
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 位置情報取得に関するアラートメソッド
        // 現在地取得していいですか？
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 位置情報が更新されるたびに呼ばれるメソッド

        guard let newLocation = locations.last else {
            return
        }
        
        // 緯度取得
        self.idoLabel.text = "".appendingFormat("%.4f", newLocation.coordinate.latitude)
        // 軽度取得
        self.keidoLabel.text = "".appendingFormat("%.4f", newLocation.coordinate.longitude)
        // 緯度経度から住所に変換する
        self.reverseGeocode(latitude: Double(idoLabel.text!)!, longitude: Double(keidoLabel.text!)!)
        
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
            
        })}
    
    // 遷移前に実行されるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createroom"{
            //パラメータを渡す(Roomを作る)
            let createRoomVC = segue.destination as! CreateRoomViewController
//            createRoomVC.uid = uid
//           createRoomVC.profileImage = profileImage
        }else if segue.identifier == "roomslist"{
            //パラメータを渡す(近くのRoomを探す)
            let roomsVC = segue.destination as! RoomsViewController
            roomsVC.uid = uid
//            roomsVC.profileImage = profileImage
            address = self.country + self.administrativeArea + self.subAdministrativeArea
            + self.locality + self.subLocality
            roomsVC.address = address
        }
    }
    
    //部屋作成ボタンを押したときのアクション
    @IBAction func goCreateRoomView(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled(){
            //ロケーションマネージャーを止める
            locationManager.stopUpdatingLocation()
        }
        self.performSegue(withIdentifier: "createroom", sender: nil)
        
    }
    
    @IBAction func searchRooms(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled(){
            //ロケーションマネージャーを止める
            locationManager.stopUpdatingLocation()
        }
        self.performSegue(withIdentifier: "roomslist", sender: nil)

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
                cameraPicker.delegate = self
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
    
    //選択した写真を背景に設置する(delegateメソッド)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //Userdefaultsへ保存
            UserDefaults.standard.set(UIImagePNGRepresentation(pickedImage), forKey: "backGroundImage")
        }
        //カメラ画面(アルバム画面)を閉じる処理
        picker.dismiss(animated: true, completion: nil)
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

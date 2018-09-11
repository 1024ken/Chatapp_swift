//
//  SelectViewController.swift
//  CloudChatRoom
//
//  Created by 渡辺健一 on 2018/09/11.
//  Copyright © 2018年 渡辺健一. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SelectViewController: UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var uid = FIRAuth.auth()?.currentUser?.uid
    
    var profileImage: NSURL!
    
    var locationManager: CLLocationManager!

    @IBOutlet weak var idoLabel: UILabel!
    
    @IBOutlet weak var keidoLabel: UILabel!
    
    //位置情報を定義
    var cuntry: String = String()
    var cuntry: administrativeArea = String()
    var cuntry: subAdministrativeArea = String()
    var cuntry: locality = String()
    var cuntry: subLocality = String()
    var cuntry: thoroughfare = String()
    var cuntry: subThoroughfare = String()
    
    var cuntry: address = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        catchLocationData()
        
    }
    
    //現在地の緯度経度を取得し、住所に変換する
    func catchLocationData(){
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    //位置情報取得に関するアラートメソッド(許可)
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
    
    // 位置情報が更新されるたびに呼ばれるメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        self.idoLabel.text = "".appendingFormat("%.4f", newLocation.coordinate.latitude)
        self.keidoLabel.text = "".appendingFormat("%.4f", newLocation.coordinate.longitude)
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
            
            //上記の位置情報を adress に置き換えている
            self.address = self.country! + self.administrativeArea! + self.subAdministrativeArea!
                + self.locality! + self.subLocality!
            
        })}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createroom" {
            
            let createRoomVC = segue.destination as! CreateRoomViewController
            
            createRoomVC.uid = uid
            
            createRoomVC.profileImage = profileImage
            
        } else if segue.identifier == "roomsList" {
            
            let roomsViewControllerVC = segue.destination as! RoomsViewController
            
            createRoomVC.uid = uid
            
            createRoomVC.profileImage = profileImage
            
            adress = self.country! + self.administrativeArea! + self.subAdministrativeArea!
                + self.locality! + self.subLocality!
            
            
            roomsVC.adress = adress
        }
        
    }
    
    
    @IBAction func goCreateRoomView(_ sender: Any) {
        
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.stopUpdatingLocation()
            
        }
        
        self.performSegue(withIdentifier: "createroom", sender: nil)
        
    }
    
    
    @IBAction func searchRooms(_ sender: Any) {
        
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.stopUpdatingLocation()
            
        }
        
        self.performSegue(withIdentifier: "roomsList", sender: nil)
        
    }
    
    
    @IBAction func backGroundPhoto(_ sender: Any) {
        
        showAlertViewController(){
        
    }
    
    //アラートを表示する
    func showAlertViewController(){
        
        //アクションシートの生成
        let alertController = UIAlertController(title: "選択してください。", message: "チャットの背景画像を変更します。", preferredStyle: .actionSheet)
        
        //ボタンを押したときの動き
        let cameraButton:UIAlertAction = UIAlertAction(title: "カメラから", style: UIAlertActionStyle.default,handler: { (action:UIAlertAction!) in
            
            let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
            
            // カメラが利用可能かチェック
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                
                // インスタンスの作成
                let cameraPicker = UIImagePickerController()
                cameraPicker.sourceType = sourceType
                cameraPicker.delegate = self
                cameraPicker.allowsEditing = true
                
                //カメラを起動
                self.present(cameraPicker, animated: true, completion: nil)
                
            }
            
        })
        
        //アルバム
        let albumButton:UIAlertAction = UIAlertAction(title: "アルバムから", style: UIAlertActionStyle.default,handler: { (action:UIAlertAction!) in
            
            let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
            
            // アルバムが利用可能かチェック
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                
                // インスタンスの作成
                let cameraPicker = UIImagePickerController()
                cameraPicker.sourceType = sourceType
                cameraPicker.delegate = self
                
                //カメラを起動
                self.present(cameraPicker, animated: true, completion: nil)
                
            }
            
        })
        
        //キャンセルボタンの定義
        let cancelButton:UIAlertAction = UIAlertAction(title: " キャンセル", style: UIAlertActionStyle.cancel,handler: { (action:UIAlertAction!) in
            
            //キャンセル
            
        })
        
        alertController.addAction(cameraButton)
        alertController.addAction(albumButton)
        alertController.addAction(cancelButton)
        
        //アラートを出す
        present(alertController, animated: true, completion: nil)
        
    }
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            
            //pickedImage の中にアルバムとカメラの画像がそれぞれ入ってくる。
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                //データ型に変更したものを Userdefaults へ保存
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
    
}

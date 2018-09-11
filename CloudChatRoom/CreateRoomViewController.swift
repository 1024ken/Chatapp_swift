//
//  CreateRoomViewController.swift
//  CloudChatRoom
//
//  Created by 渡辺健一 on 2018/09/11.
//  Copyright © 2018年 渡辺健一. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CreateRoomViewController: UIViewController {
    
    //共通化した関数を宣言
    var posts = [Post]()
    
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
    
    var data: Data = Data()
    
    var imageString: String!
    
    @IBOutlet weak var inputRoomNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //位置情報取得に関するアラートメソッド
    
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

    //次の画面に遷移する際に発動する
    func postRoom(){
        
        //showIndicatorを読み込む
        AppDelegate.instance().showIndicator()
        
        //緯度・経度から住所へ変換
        reverseGeocode(latitude: Double(idoLabel.text!)!, longitude: Double(keidoLabel.text!)!)
        
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference(forURL: "s://cloudchatroom-cfcdb.appspot.com")
        let key = ref.child("Rooms").childByAutoId().key
        let imageRef = storage.child("Rooms").child(uid!).child("\(key).png")
        
        //strageサーバーにimage を置く
        self.data = UIImageJPEGRepresentation(UIImage(named: "ownerImage.png")!, 0.6)!
        
        let uploadTask = imageRef.put(self.data, metadata: nil) { (metaData, error) in
            
            if error != nil {
                
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            
            //URLはストレージのURL
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url {
                    
                    let feed = ["userID":self.uid,"pathToImage":self.profileImage.absoluteString,"ido":self.idoLabel.text,"keido":self.keidoLabel.text,
                    "roomName":self.inputRoomNameTextField.text,"postID":key,"country":self.country,"administrativeArea":self.administrativeArea,"subAdministrativeArea":self.subAdministrativeArea,"locality":self.locality,"subLocality":self.subLocality,"thoroughfare":self.thoroughfare,"subThoroughfare":self.subThoroughfare] as [String:Any]
                    
                    
                    let postFeed = ["\(key)":feed]
                    self.imageString = self.profileImage.absoluteString
                    ref.child("Rooms").updateChildValues(postFeed)
                    
                    //上記の処理終了後、Indicatorを止める
                    AppDelegate.instance().dismissActivityIndicator()
                    
                    //画面遷移する
                    self.performSegue(withIdentifier: "room", sender: nil)
                    
                }
                
            })
            
        }
        
        uploadTask.resume()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let chatVC = segue.destination as! ChatViewController
        
        chatVC.roomName = inputRoomNameTextField.text!
        
        chatVC.address = self.additionalSafeAreaInsets
        
        chatVC.pathToImage = self.profileImage.absoluteString
        
    }
    
    //現在地の緯度経度を取得
    func catchLocationData(){
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        }
        
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

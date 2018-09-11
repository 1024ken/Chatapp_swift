//
//  LoginViewController.swift
//  CloudChatRoom
//
//  Created by 渡辺健一 on 2018/09/11.
//  Copyright © 2018年 渡辺健一. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreLocation

class LoginViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate,CLLocationManegerDelegate {
    
    var profileImage: URL!
    
    var locationManager: CLLocationManeger!
    
    var uid = FIRAuth.auth()?.currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        catchLocationData()
        
        //google sign in のボタンを生成し、大きさを指定、貼り付ける
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 20, y: 250, width: self.view.frame.size.width-40, height: 60)
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

    }
    
    //uid と plofileImage の値を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let selectVC = segue.destination as! SelectViewController
        selectVC.uid = uid
        selectVC.profileImage = self.profileImage! as NSURL
        
    }
    
    //sign in 成功時に自動的に呼ばれるメソッド
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error {
            print("エラーです。",err)
            return
        }
        
        print("成功しました！")
        UserDefaults.standard.set(0, forKey: "login")
        
        guard let idToken = user.authentication.idToken else {
            return
        }
        
        guard let accessToken = user.authentication.accessToken else{
            return
        }
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user,error) in
            if let err = error{
                print("エラー",err)
                return
            }
            
            //プロフィールイメージを取得
            let imageUrl = signIn.currentUser.profile.imageURL(withDimension: 100)
            self.profileImage = imageUrl
            self.postMyProfile()
            
            //next へ画面遷移する
            self.performSegue(withIdentifier: "next", sender: nil)
            
        })
    }
    
    func postMyProfile(){
        
        //sign in の最中にindecaterを処理している
        AppDelegate.instance().showIndicator()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference(forURL: "s://cloudchatroom-cfcdb.appspot.com")
        let key = ref.child("Users").childByAutoId().key
        
        //strageサーバーに入ってくる画像の格納場所
        let imageRef = storage.child("Users").child(uid!).child("\(key).jpg")
        
        let imageData:NSData = try! NSData(contentsOf: self.profileImage)
        
        let uploadTask = imageRef.put(imageData as Data, metadata: nil) { (metaData, error) in
            if error != nil {
                
                //エラーが出た場合に Indicator を止める
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            
            //downloadURL を生成
            imageRef.downloadURL(completion: { (url, error) in
                if url != nil {
                    
                    //userID と pathToImage を absoluteString 型へ変換している
                    let feed = ["userID":self.uid,"pathToImage":self.profileImage.absoluteString,"postID":key] as [String:Any]
                    let postFeed = ["\(key)":feed]
                    
                    //Users データベースを update
                    ref.child("Users").updateChildValues(postFeed)
                    
                    //Indicator を止める
                    AppDelegate.instance().dismissActivityIndicator()
                    
                }
                
            })
            
        }
        
        uploadTask.resume()
        
    }

    //LocationData を処理するメソッド
    func catchLocationData(){
        
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

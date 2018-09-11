//
//  Post.swift
//  CloudChatRoom
//
//  Created by 渡辺健一 on 2018/09/11.
//  Copyright © 2018年 渡辺健一. All rights reserved.
//

import UIKit

class Post: NSObject {

    //処理の共通化を行う
    var cuntry: String = String()
    var cuntry: administrativeArea = String()
    var cuntry: subAdministrativeArea = String()
    var cuntry: locality = String()
    var cuntry: subLocality = String()
    var cuntry: thoroughfare = String()
    var cuntry: subThoroughfare = String()
    
    var pathToImage: String!
    var roomName: String!
    var roomRule: String!
    var userID: String!
    
}

//
//  sessionManager.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/25/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import Foundation

class sessionManager{
    class var sharedIntance: sessionManager{
        struct Static{
            static var instance: sessionManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once (&Static.token){
            Static.instance = sessionManager ()
        }
        
        return Static.instance!
    }
    
    var selectedProject: String?
    var folderLevel : Int?
    var selectedQuery_L0 : String?
    var selectedQuery_L1 : String?
    var selectedQuery_L2 : String?
    var selectedQuery_L3 : String?
}
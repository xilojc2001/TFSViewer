//
//  ApiProxy.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/15/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import Foundation


class ApiProxy{
    
    var projectList  : Array<Project> = []
 
    struct Project {
        var id = ""
        var name = ""
        var url = ""
        var state = ""
        var revision = ""
    }
    
    init(){ }
    
    func test(){
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let userPasswordString = "xilojc2001:pass"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let authString = "Basic \(base64EncodedCredential)"
        
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        
        let session = NSURLSession(configuration: config)
        
        var running = false
        let url = NSURL(string: "https://cnxco.visualstudio.com/DefaultCollection/_apis/projects?api-version=1.0")
        
        
        
        let task = session.dataTaskWithURL(url!) {
            (let data, let response, let error) in
            if let _ = response as? NSHTTPURLResponse {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                // convertir String a NSData
                let data: NSData = dataString!.dataUsingEncoding(NSUTF8StringEncoding)!
               
                // convert NSData a 'AnyObject'
                do {
                    let anyObj: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    
                    if let dict = anyObj as? [String: AnyObject] {
                        if let objArray = dict["value"] as? [AnyObject] {
                          
                            self.projectList = self.parseJson(objArray)
                            print (self.projectList[0].name)
                        }
                    }
                }
                catch _ {
                    print ("Unable to convert NSData a AnyObject")
                }
            }
            running = false
        }
        
        running = true
        task.resume()
        
        while running {
            print("waiting...")
            sleep(1)
        }
    }
    
    func parseJson(anyObj:AnyObject) -> Array<Project>{
        
        var list:Array<Project> = []
        
        if  anyObj is Array<AnyObject> {
            
            var b:Project = Project()
            
            for json in anyObj as! Array<AnyObject>{
                b.id = (json["id"] as AnyObject? as? String) ?? ""
                b.name = (json["name"] as AnyObject? as? String) ?? ""
                b.url = (json["url"] as AnyObject? as? String) ?? ""
                b.state = (json["state"] as AnyObject? as? String) ?? ""
                b.revision = (json["revision"] as AnyObject? as? String) ?? ""
                
                list.append(b)
            }
        }
        
        return list
    }
    
}
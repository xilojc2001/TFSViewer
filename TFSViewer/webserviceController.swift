//
//  webserviceController.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/25/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class webserviceController {
    
    var projectList  : Array<Project> = []
    var queryList  : Array<Query> = []
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let sessionMng = sessionManager.sharedIntance
    
    struct Project {
        var id = ""
        var name = ""
        var url = ""
        var state = ""
        var revision = ""
    }
    
    struct Query {
        var id = ""
        var name = ""
        var path = ""
        var wiql = ""
    }
    
    init(){ }
    
    //Este metodo consulta los proyectos a traves del servicio web
    func getProjects(){
        
        //Consulto los parametros de conexión
        let context = appDel.managedObjectContext
        let configObj = NSEntityDescription.entityForName ("TfsConfiguration", inManagedObjectContext: context)
        let oConfig = TfsConfiguration(entity: configObj! ,insertIntoManagedObjectContext: context)
        oConfig.getConfig()
        
        //Inicializo las variables necesarias para el consumo de los servicios
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let userPasswordString = oConfig.username! + ":" + oConfig.password!
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let authString = "Basic \(base64EncodedCredential)"
        
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        
        let session = NSURLSession(configuration: config)
        
        var running = false
        let url = NSURL(string: "https://" + oConfig.account + ".visualstudio.com/DefaultCollection/_apis/projects?api-version=" + (oConfig.api?.stringValue)!)
        
        let task = session.dataTaskWithURL(url!) {
            (let data, let response, let error) in
            if let _ = response as? NSHTTPURLResponse {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                // convertir String a NSData
                let data: NSData = dataString!.dataUsingEncoding(NSUTF8StringEncoding)!
                
                // convert NSData a 'AnyObject'
                do {
                    let anyObj: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    
                    //Si la consulta del servicio arroja datos, los pasa de json a objetos
                    if let dict = anyObj as? [String: AnyObject] {
                        if let objArray = dict["value"] as? [AnyObject] {
                            self.projectList = self.parseJsonProjects(objArray)
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
    
    //Este metodo convierte los resultados json del servicio a objetos
    func parseJsonProjects(anyObj:AnyObject) -> Array<Project>{
        
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
    
    //Este metodo consulta los queries a traves del servicio web
    func getQueries(){
        
        //Consulto los parametros de conexión
        let context = appDel.managedObjectContext
        let configObj = NSEntityDescription.entityForName ("TfsConfiguration", inManagedObjectContext: context)
        let oConfig = TfsConfiguration(entity: configObj! ,insertIntoManagedObjectContext: context)
        oConfig.getConfig()
        
        //Inicializo las variables necesarias para el consumo de los servicios
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let userPasswordString = oConfig.username! + ":" + oConfig.password!
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let authString = "Basic \(base64EncodedCredential)"
        
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        
        let session = NSURLSession(configuration: config)
        var running = false
        
        //Defino las variables que se requieren para construir la cadena de la consulta del servicio
        var urlBase : String = ""
        var api: String = ""
        var finalURL : String = ""
        var folderLevel : Int = 0
        var selectedQuery : String = ""
        
        //Defino la estructura de la cadena base que no cambia a lo largo de las consultas
        if let account : String = oConfig.account, let selPro : String = sessionMng.selectedProject {
            urlBase = "https://" + account + ".visualstudio.com/DefaultCollection/" + selPro + "/_apis/wit/queries"
        }
        
        //Defino una variable que me permite eliminar lo opcional de la variable
        if let apiOpt : String = oConfig.api!.stringValue {
           api = apiOpt
        }
        
        //Defino una variable que me permite eliminar lo opcional de la variable
        if let folderLevelOpt : Int = sessionMng.folderLevel  {
            folderLevel = folderLevelOpt
        }
        
        //Defino una variable que me permite eliminar lo opcional de la variable
        if let selectedQueryOpt : String = sessionMng.selectedQuery  {
            selectedQuery = selectedQueryOpt
        }
        
        switch folderLevel {
            case 0 :
                    finalURL = urlBase + "?api-version=" + api
            case 1 :
                    finalURL = urlBase + "/" + selectedQuery + "?$depth=1&api-version=" + api
            default :
                finalURL = finalURL + ""
        }
        
        //Me aseguro de que el arreglo en donde va a guardar la informacion este vacio
        self.queryList.removeAll()
        
        //Codifico la cadena para que los espacios y demas caracteres especiales no generen inconvenientes
        finalURL = finalURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlWS = NSURL (string: finalURL)
        
        let task = session.dataTaskWithURL(urlWS!) {
            (let data, let response, let error) in
            if let _ = response as? NSHTTPURLResponse {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                // convertir String a NSData
                let data: NSData = dataString!.dataUsingEncoding(NSUTF8StringEncoding)!
                
                // convert NSData a 'AnyObject'
                do {
                    let anyObj: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    
                    if folderLevel == 0{
                        //Si la consulta del servicio arroja datos, los pasa de json a objetos
                        if let dict = anyObj as? [String: AnyObject] {
                            if let objArray = dict["value"] as? [AnyObject] {
                                self.queryList = self.parseJsonQueries(objArray)
                            }
                        }
                    }
                    
                    if folderLevel == 1{
                        //Si la consulta del servicio arroja datos, los pasa de json a objetos
                        if let dict = anyObj as? [String: AnyObject] {
                            if let objArray = dict["children"] as? [AnyObject] {
                                self.queryList = self.parseJsonQueries(objArray)
                            }
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
    
    //Este metodo convierte los resultados json del servicio a objetos
    func parseJsonQueries(anyObj:AnyObject) -> Array<Query>{
        
        var list:Array<Query> = []
        
        if  anyObj is Array<AnyObject> {
            
            var b:Query = Query()
            
            for json in anyObj as! Array<AnyObject>{
                b.id = (json["id"] as AnyObject? as? String) ?? ""
                b.name = (json["name"] as AnyObject? as? String) ?? ""
                b.path = (json["path"] as AnyObject? as? String) ?? ""
                b.wiql = (json["wiql"] as AnyObject? as? String) ?? ""
                
                list.append(b)                
            }
        }
        
        return list
    }
    
}
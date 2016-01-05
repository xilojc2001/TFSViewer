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
    var dataQueryList  : Array<dataQuery> = []
    var urlList : Array<String> = []
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
        var isFolder = false
    }
    
    struct dataQuery {
        var ID = 0
        var Work_Item_Type = ""
        var Title = ""
        var Assigned_To = ""
        var State = ""
        var Remaining_Work = 0.0
        var Activity = ""
        var Iteration_Path = ""
        var Original_Estimate = 0.0
        var Completed_Work = 0.0
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
            print("waiting WS response...")
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
    func getQueries(wiql: String = "", workItem: String = ""){
        
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
        var selectedQuery_L0 : String = ""
        var selectedQuery_L1 : String = ""
        var selectedQuery_L2 : String = ""
        var selectedQuery_L3 : String = ""
        
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
        
        //Si se especifica un url que corresponde a un Query particular, se utiliza ese url
        if wiql != "" {
            if workItem == ""{
               finalURL = wiql
            }else{
               finalURL = workItem
            }
            
        } else {
            //Defino una variable que me permite eliminar lo opcional de la variable
            if let selectedQueryOpt : String = sessionMng.selectedQuery_L0  {
                selectedQuery_L0 = selectedQueryOpt
            }
            
            if let selectedQueryOpt : String = sessionMng.selectedQuery_L1  {
                selectedQuery_L1 = selectedQueryOpt
            }
            
            if let selectedQueryOpt : String = sessionMng.selectedQuery_L2  {
                selectedQuery_L2 = selectedQueryOpt
            }
            
            if let selectedQueryOpt : String = sessionMng.selectedQuery_L3  {
                selectedQuery_L3 = selectedQueryOpt
            }
            
            switch folderLevel {
                case 0 :
                        finalURL = urlBase + "?api-version=" + api
                case 1 :
                        finalURL = urlBase + "/" + selectedQuery_L0 + "?$depth=1&api-version=" + api
                case 2 :
                        finalURL = urlBase + "/" + selectedQuery_L0 + "/" + selectedQuery_L1 +  "?$depth=1&api-version=" + api
                case 3 :
                        finalURL = urlBase + "/" + selectedQuery_L0 + "/" + selectedQuery_L1 + "/" + selectedQuery_L2 + "?$depth=1&api-version=" + api
                case 4 :
                        finalURL = urlBase + "/" + selectedQuery_L0 + "/" + selectedQuery_L1 + "/" + selectedQuery_L2 + "/" + selectedQuery_L3 + "?$depth=1&api-version=" + api
                default :
                    finalURL = finalURL + ""
            }
        }
        
        //print ("URl Generado: \(finalURL)")
        
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
                    } else {
                        if wiql == "" && workItem == "" {
                            //Si la consulta del servicio arroja datos, los pasa de json a objetos
                            if let dict = anyObj as? [String: AnyObject] {
                                if let objArray = dict["children"] as? [AnyObject] {
                                    self.queryList = self.parseJsonQueries(objArray)
                                }
                            }
                        }
                        
                        if wiql != "" && workItem == ""{
                            //Si la consulta del servicio arroja datos, los pasa de json a objetos
                            if let dict = anyObj as? [String: AnyObject] {
                                
                                //Elimino los datos que puedan existir en los arreglos de urls y de datos de query
                                self.urlList.removeAll()
                                self.dataQueryList.removeAll()
                                
                                //Para algunos proyectos el arreglo de items se llama workItems
                                if let objArray = dict["workItems"] as? [AnyObject] {
                                    self.parseJsonWorkItems(objArray)
                                }
                                
                                //Para otros proyectos el arreglo de items se llama workItemRelations
                                if let objArray = dict["workItemRelations"] as? [AnyObject] {
                                    self.parseJsonWorkItems(objArray)
                                }
                            }
                        }
                        
                        if wiql != "" && workItem != ""{
                            //Si la consulta del servicio arroja datos, los pasa de json a objetos
                            if let dataWI = anyObj as? [String: AnyObject] {
                                let id = dataWI["id"]! as AnyObject
                                let obj = dataWI["fields"]! as AnyObject
                                self.parseJsonDataQuery(id,anyObj: obj)
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
            print("waiting WS response...")
            sleep(1)
        }
      
    }
    
    //Este metodo convierte los resultados json del servicio a objetos
    func parseJsonQueries(anyObj:AnyObject) -> Array<Query>{
        
        var list:Array<Query> = []
        var isFolder : Bool
        
        if  anyObj is Array<AnyObject> {
            
            var b:Query = Query()
            
            for json in anyObj as! Array<AnyObject>{
                b.id = (json["id"] as AnyObject? as? String) ?? ""
                b.name = (json["name"] as AnyObject? as? String) ?? ""
                b.path = (json["path"] as AnyObject? as? String) ?? ""
                
                //Se identifica si es un folder lo que se esta procesando
                isFolder = false
                isFolder = (json["isFolder"] as AnyObject? as? Bool) ?? false
                b.isFolder = isFolder
                
                if let dict = json["_links"] as? [String: AnyObject] {
                    if let wiql = dict["wiql"] as? [String: AnyObject] {
                        b.wiql = (wiql["href"] as AnyObject? as? String) ?? ""
                    }
                }
                
                
                list.append(b)
            }
        }
        
        return list
    }
    
    //Este metodo convierte los resultados json del servicio a objetos
    func parseJsonWorkItems(anyObj:AnyObject){
        if  anyObj is Array<AnyObject> {
            
            var b:String = ""
            
            for json in anyObj as! Array<AnyObject>{
                b = (json["url"] as AnyObject? as? String) ?? ""
                self.urlList.append(b)
            }
        }
    }
    
    //Este metodo convierte los resultados json del servicio a objetos
    func parseJsonDataQuery(id:AnyObject , anyObj:AnyObject){
        var b:dataQuery = dataQuery()
    
        b.ID = (id as AnyObject? as! Int)
        b.Work_Item_Type = (anyObj["System.WorkItemType"] as AnyObject? as? String) ?? ""
        b.Title = (anyObj["System.Title"] as AnyObject? as? String) ?? ""
        b.Assigned_To = (anyObj["System.AssignedTo"] as AnyObject? as? String) ?? ""
        b.State = (anyObj["System.State"] as AnyObject? as? String) ?? ""
        b.Remaining_Work = (anyObj["Microsoft.VSTS.Scheduling.RemainingWork"] as AnyObject? as? Double) ?? 0
        b.Activity = (anyObj["Microsoft.VSTS.Common.Activity"] as AnyObject? as? String) ?? ""
        b.Iteration_Path = (anyObj["System.IterationPath"] as AnyObject? as? String) ?? ""
        b.Original_Estimate = (anyObj["Microsoft.VSTS.Scheduling.OriginalEstimate"] as AnyObject? as? Double) ?? 0
        b.Completed_Work = (anyObj["Microsoft.VSTS.Scheduling.CompletedWork"] as AnyObject? as? Double) ?? 0
        
        dataQueryList.append(b)
    }
    
}
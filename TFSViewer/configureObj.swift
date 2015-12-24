//
//  configureObj.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/15/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class configureObj {
    private var account: String
    private var api: NSDecimalNumber
    private var apiString: String
    private var username : String
    private var password : String
    
    //Definicion de variables especificas para acceso a sqllite
    let appDel : AppDelegate
    let context : NSManagedObjectContext
    
    init (account: String, api: NSDecimalNumber, apiString:String, username: String, password: String){
        self.account = account
        self.api = api
        self.apiString = apiString
        self.username = username
        self.password = password
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDel.managedObjectContext
    }
    
    func getAccount() -> String {
      return self.account
    }
    
    func setAccount (account: String){
        self.account = account
    }
    
    func getApi() -> NSDecimalNumber {
        return self.api
    }
    
    func setApi (api: NSDecimalNumber){
        self.api = api
    }
    
    func getApiString() -> String {
        return self.apiString
    }
    
    func setApiString (api: String){
        self.apiString = api
    }
    
    func getUsername() -> String {
        return self.username
    }
    
    func setUsername (username: String){
        self.username = username
    }
    
    func getPassword() -> String {
        return self.password
    }
    
    func setPassword (password: String){
        self.password = password
    }
    
    //Funcion encargada de almacenar la información de configuración del TFS
    func saveConfig () -> String{
        var result : String
        
        //Se debe almacenar la nueva información
        let newConfig = NSEntityDescription.insertNewObjectForEntityForName("TfsConfiguration", inManagedObjectContext: context) as NSManagedObject
        
        newConfig.setValue(self.account, forKey: "account")
        newConfig.setValue(self.api , forKey: "api")
        newConfig.setValue(self.username , forKey: "username")
        newConfig.setValue(self.password , forKey: "password")
        
        //Se procede a intentar almacenar la información
        do {
            try context.save()
            result = "TFS Configuration Saved!"
        }
        catch _ {
            result = "Unable to save TFS Configuration"
        }
        
        //Se debe mostrar al usuario un mensaje indicando que la información fue guardada
        return result
    }
    
    
    //Funcion encargada de obtener la información de configuración del TFS
    func resetConfig () {
        let request = NSFetchRequest (entityName: "TfsConfiguration")
     
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.executeRequest(deleteRequest)
        } catch _ as NSError {
            print ("Unable to delete data from TFS Configuration")
        }
    }
    
    //Funcion encargada de obtener la información de configuración del TFS
    func getConfig (){
        let request = NSFetchRequest (entityName: "TfsConfiguration")
        var results : NSArray
        
        request.returnsObjectsAsFaults = false
        results = NSArray ()
        
        //Se intenta obtener todos los registros de la tabla
        do {
            try results = context.executeFetchRequest(request)
        }
        catch _ {
            print ("Unable to retrieve data from TFS Configuration")
        }
        
        //En caso que haya resultado, se debe mostrar la información previamente guardada en los campos
        if (results.count > 0 ){
            let res = results [0]
            
            if let accountString = res.valueForKey ("account") as? NSString {
                self.setAccount(accountString as String)
            }
            
            if let apiDecimal = res.valueForKey ("api") as? NSDecimalNumber {
                self.setApiString(apiDecimal.stringValue)
            }
            
            if let usernameString = res.valueForKey ("username") as? NSString {
                self.setUsername(usernameString as String)
            }
            
            if let passwordString = res.valueForKey ("password") as? NSString {
                self.setPassword(passwordString as String)
            }
            
        }else
        {
            print ("Unable to retrieve data from TFS Configuration")
        }
       
    }
}
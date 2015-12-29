//
//  TfsConfiguration.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/25/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TfsConfiguration: NSManagedObject {
    
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate    
    
    //Funcion encargada de almacenar la información de configuración del TFS
    func saveConfig () -> String{
        var result : String
        
        //Defino una variable para tener acceso al contexto de la aplicación
        let context = appDel.managedObjectContext
  
        //Se debe almacenar la nueva información
        self.setValue(self.account, forKey: "account")
        self.setValue(self.api , forKey: "api")
        self.setValue(self.username , forKey: "username")
        self.setValue(self.password , forKey: "password")
        
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
    func resetConfig () -> String {
        var result : String
        
        //Defino una variable para tener acceso al contexto de la aplicación
        let context = appDel.managedObjectContext
        
        let request = NSFetchRequest (entityName: "TfsConfiguration")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.executeRequest(deleteRequest)
            result = "TFS Configuration Reset!"
        } catch _ as NSError {
             result = "Unable to reset TFS Configuration"
        }
        
        //Se debe mostrar al usuario un mensaje indicando que la información fue reiniciada
        return result
    }
    
    //Funcion encargada de obtener la información de configuración del TFS
    func getConfig (){
        //Defino una variable para tener acceso al contexto de la aplicación
        let context = appDel.managedObjectContext
        
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
        for resultItem in results {
            let tfsItem = resultItem as! TfsConfiguration
            
            if tfsItem.password != nil {
                self.account = tfsItem.account
                self.api = tfsItem.api
                self.username = tfsItem.username
                self.password = tfsItem.password
            }
   
        }
    }

}

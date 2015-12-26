//
//  configureViewController.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/13/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import UIKit
import CoreData

class configureViewController: UIViewController {
    
    
    //Defino los objetos que se van a enlazar entre la vista y el codigo
    //Estos objetos unicamente se llenarian cuando se ingrese a la opción de configuración
    //de lo contrario van a estar vacios
    @IBOutlet var txtAccount : UITextField!
    @IBOutlet var txtApi : UITextField!
    @IBOutlet var txtUserName: UITextField!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var txtPassword: UITextField!
    
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let sessionMng = sessionManager.sharedIntance
 
    //Esta funcion se encarga de tomar los datos de la pantalla y almacenarlos en la base de datos
    @IBAction func btnSave (){
        //Establezco el objeto en el que se van a almacenar las configuraciones iniciales
        let context = appDel.managedObjectContext
        let configObj = NSEntityDescription.insertNewObjectForEntityForName("TfsConfiguration", inManagedObjectContext: context)
        let oConfig = TfsConfiguration(entity: configObj.entity,insertIntoManagedObjectContext: context)
        
        //Inicializo la variable con la informacion de la configuración
        var result : String
        
        //Si se ha definido valor para la cuenta lo establezco
        if txtAccount.text != "" {
            oConfig.setValue(txtAccount.text, forKey: "account")
        }
        
        //Si se ha definido valor para el api lo establezco
        if txtApi.text != "" {
            oConfig.setValue(NSDecimalNumber(string: txtApi.text) , forKey: "api")
        } else{
            oConfig.setValue(1.0, forKey: "api")
        }
        
        //Si se ha definido valor para el usuario lo establezco
        if txtUserName.text != "" {
            oConfig.setValue(txtUserName.text , forKey: "username")
        }
        
        //Si se ha definido valor para el password lo establezco
        if txtPassword.text != "" {
            oConfig.setValue(txtPassword.text, forKey: "password")
        }
      
        //Se elimina la informaciòn de configuración previa que peuda haber
        oConfig.resetConfig()
        
        //Se procede a almacenar a informacion ingresada
        result = oConfig.saveConfig()
        
        //Se presenta el mensaje resultado
        lblMessage.text=result
    }
    
    @IBAction func btnReset(){
        //Inicializo la variable con la informacion de la configuración
        var result : String
        
        //Establezco el objeto en el que se van a almacenar las configuraciones iniciales
        let context = appDel.managedObjectContext
        let configObj = NSEntityDescription.entityForName ("TfsConfiguration", inManagedObjectContext: context)
        let oConfig = TfsConfiguration(entity: configObj! ,insertIntoManagedObjectContext: context)
        
        result = oConfig.resetConfig()
        
        //Se presenta el mensaje resultado
        lblMessage.text=result
        
        //Refrescar la visualizacion de la configuración
        loadInitData ()
    }
    
    //Esta funcion se encarga de leer la información de la base de datos y cargar el objeto de configuración
    //con los datos que se lograron extraer
    func loadInitData (){
        //Establezco el objeto en el que se van a almacenar las configuraciones iniciales
        let context = appDel.managedObjectContext
        let configObj = NSEntityDescription.entityForName ("TfsConfiguration", inManagedObjectContext: context)
        let oConfig = TfsConfiguration(entity: configObj! ,insertIntoManagedObjectContext: context)
        
        //Obtener la información de la configuración
        oConfig.getConfig()
        
        //En caso que haya resultado, se debe mostrar la información previamente guardada en los campos
        txtAccount.text = oConfig.account
        txtApi.text = oConfig.api?.stringValue
        txtUserName.text = oConfig.username
        txtPassword.text = oConfig.password
        lblMessage.text = ""
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitData ()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


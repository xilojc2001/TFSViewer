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
    @IBOutlet var txtAccount : UITextField!
    @IBOutlet var txtApi : UITextField!
    @IBOutlet var txtUserName: UITextField!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var txtPassword: UITextField!
    
    @IBAction func btnSave (){
        //Inicializo la variable con la informacion de la configuración
        let oConfig = configureObj(account: "", api: NSDecimalNumber(string: "0"), apiString: "", username: "", password: "")
        var result : String
        
        //Si se ha definido valor para la cuenta lo establezco
        if txtAccount.text != "" {
            oConfig.setAccount(txtAccount.text!)
        }
        
        //Si se ha definido valor para el api lo establezco
        if txtApi.text != "" {
            oConfig.setApi(NSDecimalNumber(string: txtApi.text))
            oConfig.setApiString(txtApi.text!)
        }
        
        //Si se ha definido valor para el usuario lo establezco
        if txtUserName.text != "" {
            oConfig.setUsername(txtUserName.text!)
        }
        
        //Si se ha definido valor para el password lo establezco
        if txtPassword.text != "" {
            oConfig.setPassword(txtPassword.text!)
        }
      
        //Se elimina la informaciòn de configuración previa que peuda haber
        oConfig.resetConfig()
        
        //Se procede a almacenar a informacion ingresada
        result = oConfig.saveConfig()
        
        //Se presenta el mensaje resultado
        lblMessage.text=result
    }
    
    @IBAction func btnCancel(){
        loadInitData ()
    }
    
    func loadInitData (){
        //Inicializo la variable con la informacion de la configuración
        let oConfig = configureObj(account: "", api: NSDecimalNumber(string: "0"), apiString: "", username: "", password: "")
        
        //Obtener la información de la configuración
        oConfig.getConfig()
        
        //En caso que haya resultado, se debe mostrar la información previamente guardada en los campos
        txtAccount.text = oConfig.getAccount()
        txtApi.text = oConfig.getApiString()
        txtUserName.text = oConfig.getUsername()
        txtPassword.text = oConfig.getPassword()
        lblMessage.text = ""
        
        //prueba invocacion del servicio web
        let apitest = ApiProxy()
        apitest.test()
        
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


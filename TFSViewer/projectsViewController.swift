//
//  projectsViewController.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/13/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import UIKit
import CoreData


class projectsViewController: UIViewController, UIPickerViewDelegate {
    
    var projects = ["P1","P2","P3","P4"]
    
    @IBOutlet weak var selectedProject: UILabel!
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
       return projects.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return projects[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let projectSelection = projects [row]
        selectedProject.text = "Selected Project" + projectSelection
        
        //Establezco el objeto en el que se van a almacenar las configuraciones iniciales
        let context = appDel.managedObjectContext
        let configObj = NSEntityDescription.entityForName ("TfsConfiguration", inManagedObjectContext: context)
        let oConfig = TfsConfiguration(entity: configObj! ,insertIntoManagedObjectContext: context)
        oConfig.getConfig()
        
        //selectedProject.text = "Selected Project" + projects [0]
        selectedProject.text = oConfig.account
  
        print ("Hola \(oConfig.account)")
        
        
    }
}

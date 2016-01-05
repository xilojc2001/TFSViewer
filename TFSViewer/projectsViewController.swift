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
    @IBOutlet weak var selectedProject: UILabel!
    
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let sessionMng = sessionManager.sharedIntance
    var projectsList = [""]
    
    //Variables para controlar los controles de la barra inferior
    var tabBarItemWork: UITabBarItem = UITabBarItem()
    var tabBarItemTest: UITabBarItem = UITabBarItem()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let wsc = webserviceController()
        wsc.getProjects()
        
        //Se recorre al arreglo de proyectos
        for resultItem in wsc.projectList {
            projectsList.append(resultItem.name)
        }
        
        projectsList.sortInPlace()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
       return projectsList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return projectsList[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let projectSelection = projectsList [row]
        sessionMng.selectedProject = projectSelection
        
        //Una vez seleccionado el proyecto se pueden habilitar los otros botones de la barra
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if sessionMng.selectedProject != "" {
             if let arrayOfTabBarItems = tabBarControllerItems as! AnyObject as? NSArray{
                tabBarItemWork = arrayOfTabBarItems[2] as! UITabBarItem
                tabBarItemWork.enabled = true
                
                tabBarItemTest = arrayOfTabBarItems[3] as! UITabBarItem
                tabBarItemTest.enabled = false
                
            }
        }
    }
}

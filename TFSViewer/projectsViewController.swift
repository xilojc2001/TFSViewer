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
    
    var projectsList = [""]
    var listCount : Int = 0
    
    @IBOutlet weak var selectedProject: UILabel!
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        let api = ApiProxy()
        api.getProjects() 
        
        //Se recorre al arreglo de proyectos
        for resultItem in api.projectList {
            projectsList.append(resultItem.name)
        }
        
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
       return projectsList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return projectsList[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let projectSelection = projectsList [row]
        selectedProject.text = "Selected Project" + projectSelection
    }
}

//
//  workViewController.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/13/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import UIKit

class workViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    let sessionMng = sessionManager.sharedIntance
    
    @IBOutlet var tableView: UITableView!
    
    var queryList = [""]
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        showQueryFolders()
        super.viewDidLoad()
    }
    
    func showQueryFolders(){
        let wsc = webserviceController()
        
        //Identifico si ya se ha consultado algun otro nivel
        if sessionMng.folderLevel == nil {
            sessionMng.folderLevel = 0
        }
        
        //Elimino los datos previamente almacenados
        self.queryList.removeAll()
        
        //Obtengo los queries que corresponden al nivel
        wsc.getQueries()
        
        //Se recorre al arreglo de proyectos
        for resultItem in wsc.queryList {
            self.queryList.append(resultItem.name)
        }
        
        self.queryList.sortInPlace()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = queryList[row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        sessionMng.selectedQuery = queryList[row]
        sessionMng.folderLevel = sessionMng.folderLevel! + 1
        showQueryFolders()
        tableView.reloadData()
    }
}
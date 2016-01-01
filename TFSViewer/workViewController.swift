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
    let wsc = webserviceController()
    
    @IBOutlet var lblChoose: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var queryList : [query] = []
    var dataQueryList : [dataQuery] = []
    let textCellIdentifier = "TextCell"
    
    struct query {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        showQueryFolders()
    }
    
    func showQueryFolders(){
         //Identifico si ya se ha consultado algun otro nivel
        if sessionMng.folderLevel == nil {
            sessionMng.folderLevel = 0
        }
        
        //Elimino los datos previamente almacenados
        self.queryList.removeAll()
        
        //Obtengo los queries que corresponden al nivel
        wsc.getQueries()
        
        //Se recorre al arreglo de queries
        for resultItem in wsc.queryList {
            var tempQuery = query()
            tempQuery.id = resultItem.id
            tempQuery.name = resultItem.name
            tempQuery.path = resultItem.path
            tempQuery.wiql = resultItem.wiql
            tempQuery.isFolder = resultItem.isFolder
            
            self.queryList.append(tempQuery)
        }
        
        //Se ordena el arreglo por el campo Name, en forma ascendente
        self.queryList.sortInPlace({ $0.name < $1.name })
        
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
        cell.textLabel?.text = queryList[row].name
        
        let queryImage = UIImage(named: "queryButton")        
        let folderImage = UIImage(named: "folderButton")
        
        if queryList[row].isFolder {
            cell.imageView?.image = folderImage
        } else {
            cell.imageView?.image = queryImage
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        
        //Almaceno la información dependiendo del nivel
        if sessionMng.folderLevel == 0 {
           sessionMng.selectedQuery_L0 = queryList[row].name
        }else if sessionMng.folderLevel == 1 {
            sessionMng.selectedQuery_L1 = queryList[row].name
        }else if sessionMng.folderLevel == 2 {
            sessionMng.selectedQuery_L2 = queryList[row].name
        }else if sessionMng.folderLevel == 3 {
            sessionMng.selectedQuery_L3 = queryList[row].name
        }
        
        //Valido si se ha seleccionado un folder o un query
        if queryList[row].isFolder {
            sessionMng.folderLevel = sessionMng.folderLevel! + 1
            
            //Si se selecciona un registro de la tabla, se debe volver a consultar teniendo en cuenta el nuevo registro
            showQueryFolders()
            tableView.reloadData()
        }else{
            showDataQuery(queryList[row].wiql)
        }
    }
    
    //Esta funcion se encarga de regresar un nivel en la seleccion de queries
    @IBAction func btnBack (){
        if sessionMng.folderLevel != 0 {
            tableView.hidden=false
            lblChoose.hidden=false
            sessionMng.folderLevel = sessionMng.folderLevel! - 1
            
            //Si se selecciona un registro de la tabla, se debe volver a consultar teniendo en cuenta el nuevo registro
            showQueryFolders()
            tableView.reloadData()
        }
        
    }
    
    func showDataQuery(query: String){
        //Oculto las etiqueta que no se requieren
        tableView.hidden=true
        lblChoose.hidden=true
        
        //Obtengo los datos asociados al query 
        wsc.getQueries(query)
        
        for workItem in wsc.urlList{
            wsc.getQueries(query,workItem: workItem)
        }
        
        //Se recorre al arreglo de proyectos
        for resultItem in wsc.dataQueryList {
            var tempDataQuery = dataQuery()
            tempDataQuery.ID = resultItem.ID
            tempDataQuery.Work_Item_Type = resultItem.Work_Item_Type
            tempDataQuery.Title = resultItem.Title
            tempDataQuery.Assigned_To = resultItem.Assigned_To
            tempDataQuery.State = resultItem.State
            tempDataQuery.Remaining_Work = resultItem.Remaining_Work
            tempDataQuery.Activity = resultItem.Activity
            tempDataQuery.Iteration_Path = resultItem.Iteration_Path
            tempDataQuery.Original_Estimate = resultItem.Original_Estimate
            tempDataQuery.Completed_Work = resultItem.Completed_Work
            
            self.dataQueryList.append(tempDataQuery)
        }
        
    }
}
//
//  workViewController.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/13/15.
//  Copyright © 2015 Xilo. All rights reserved.
//

import UIKit
import Charts

class workViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    let sessionMng = sessionManager.sharedIntance
    let wsc = webserviceController()
    
    @IBOutlet var lblChoose: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet var pieChartView: PieChartView!
    @IBOutlet var btnNext: UIBarButtonItem!
    @IBOutlet var btnSave: UIBarButtonItem!
    
    var queryList : [query] = []
    var dataQueryList : [dataQuery] = []
    let textCellIdentifier = "TextCell"
    var dataLabels : [String] = []
    var dataDoubles : [Double] = []
    
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
    
    //Esta funcion es la que se ejecuta cuando el sistema identifica que el viewcontroller va a ser mostrado
    override func viewWillAppear(animated: Bool) {
        showQueryFolders()
    }
    
    //Esta funcion es la que se encarga de hacer las consultas al servicio web y adicionar los queries
    //en el arreglo de queries
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
    
    //Esta funcion es la que se encarga de procesar la seleccion del query
    //si es un folder ejecuta una nueva consulta y trae los queries
    //pero si es un query lo ejecuta y trae los datos del servicio
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
            sessionMng.chartPage = 1
            groupDataQueryList ()
            barChartView.hidden = false
            pieChartView.hidden = true
            btnNext.enabled = true
            btnSave.enabled = true
        }
    }
    
    //Esta funcion es la que se encarga de procesar lo que se consulto de los servicios y agruparlo para
    //poder graficarlo
    func groupDataQueryList (){
        //Se elimina la informacion previa que pueda tener los arreglos
        self.dataLabels = []
        self.dataDoubles = []
        
        //La grafica que se ha definido para la pagina 1 es una grafica de barras
        //que muestra el trabajo total COMPLETADO por persona
        if sessionMng.chartPage == 1{
            for dataQueryObj in self.dataQueryList {
                if self.dataLabels.indexOf(dataQueryObj.Assigned_To) == nil{
                    self.dataLabels.append(dataQueryObj.Assigned_To)
                    self.dataDoubles.append(dataQueryObj.Completed_Work)
                }else{
                    self.dataDoubles[dataLabels.indexOf(dataQueryObj.Assigned_To)!] = self.dataDoubles[self.dataLabels.indexOf(dataQueryObj.Assigned_To)!] + dataQueryObj.Completed_Work
                }
            }
            
            setBarChart(self.dataLabels, values: self.dataDoubles, label: "Completed Work")
        }
        
        //La grafica que se ha definido para la pagina 2 es una grafica de pastel
        //que muestra los items por estado
        if sessionMng.chartPage == 2{
            for dataQueryObj in self.dataQueryList {
                if self.dataLabels.indexOf(dataQueryObj.State) == nil{
                    self.dataLabels.append(dataQueryObj.State)
                    self.dataDoubles.append(1)
                }else{
                    self.dataDoubles[self.dataLabels.indexOf(dataQueryObj.State)!] = self.dataDoubles[dataLabels.indexOf(dataQueryObj.State)!] + 1
                }
            }
            
            setPieChart(self.dataLabels, values: self.dataDoubles, label: "Items By State")
        }
        
    }
    
    //Esta funcion se encarga de regresar un nivel en la seleccion de queries o a la grafica anterior
    @IBAction func btnBack (){
        if sessionMng.folderLevel != 0 && sessionMng.chartPage == 1 {
            tableView.hidden=false
            lblChoose.hidden=false            
            sessionMng.folderLevel = sessionMng.folderLevel! - 1
            
            //Si se selecciona un registro de la tabla, se debe volver a consultar teniendo en cuenta el nuevo registro
            showQueryFolders()
            tableView.reloadData()
        }
        
        if sessionMng.chartPage == 1 {
            barChartView.hidden = true
            pieChartView.hidden = true
            btnNext.enabled = false
            btnSave.enabled = false
        }
        
        if sessionMng.chartPage == 2 {
            sessionMng.chartPage = 1
            groupDataQueryList ()
            barChartView.hidden = false
            pieChartView.hidden = true
        }
    }
    
    //Esta funcion permite avanzar en las diferentes graficas
    @IBAction func btnNext_Act() {
        if sessionMng.chartPage == 1 {
            sessionMng.chartPage = 2
            groupDataQueryList ()
            barChartView.hidden = true
            pieChartView.hidden = false
        }
    }
    
    //Esta funcion permite controlar lo que va a hacer el boton de Guardar
    @IBAction func btnSave_Act() {
        if sessionMng.chartPage == 1 {
            barChartView.saveToCameraRoll()
        }
        
        if sessionMng.chartPage == 2 {
            pieChartView.saveToCameraRoll()
        }
    }
    
    func showDataQuery(query: String){
        //Oculto las etiqueta que no se requieren
        tableView.hidden=true
        lblChoose.hidden=true
        
        //Obtengo los datos asociados al query
        wsc.getQueries(query)
        
        //Por cada uno de los items, debo hacer el llamado al servicio y consultar los datos especificos
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
    
    func setBarChart(dataPoints: [String], values: [Double], label: String) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: label)
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.descriptionText = ""
        
        //Para establecer los colores de las barras (liberty,joyful,pastel,colorful,vordiplom)
        chartDataSet.colors = ChartColorTemplates.joyful()
        
        //Para cambiar la posicion
        barChartView.xAxis.labelPosition = .Bottom
        
        //Animacion de la visualizacion
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    func setPieChart(dataPoints: [String], values: [Double], label: String) {
        pieChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: label)
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
    }
}
//
//  StatisticViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import Charts

class StatisticViewController: UIViewController {
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var viewChart: BarChartView!
    
    var weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //#1 Initialize chart
        self.initializeChart()
        
        //#2 Load data to chart
        self.loadDataInChart()
    }
    
    func initializeChart() {
        
        viewChart.noDataText = "Нет Данных"
        viewChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        viewChart.xAxis.labelPosition = .bottom
        viewChart.descriptionText = ""
        //viewChart.xAxis.setLabelsToSkip(0)
        viewChart.xAxis.setLabelCount(0, force: true)
        //chart.getAxisLeft().setLabelCount(5, true);
        
        viewChart.legend.enabled = false
        viewChart.scaleYEnabled = false
        viewChart.scaleXEnabled = false
        viewChart.doubleTapToZoomEnabled = false
        viewChart.leftAxis.axisMinimum = 0.0
        viewChart.leftAxis.axisMaximum = 100.0
        viewChart.highlighter = nil
        viewChart.rightAxis.enabled = false
        viewChart.xAxis.drawGridLinesEnabled = false
        
    }
    
    func loadDataInChart() {
        
        APIManager.shared.getDriverRevenue { (json) in
            if json != nil {
                let revenue = json["revenue"]
                let dataEntries: [BarChartDataEntry] = []
                
                for i in 0..<self.weekdays.count {
                    //let day = self.weekdays[i]
                    //self.weekdays[0] = "10"
                    //   let dataEntry = BarChartDataEntry(yVals: revenue[day].double, xIndex: i)
                    //   dataEntries.append(dataEntry)
                    //  let dataEntry = BarChartDataEntry(x: Double(i), yValues: [revenue[day].double!])
                    //  dataEntries.append(dataEntry)
                }
                let chartDataSet = BarChartDataSet(values: dataEntries, label: "Revenue by day")
                chartDataSet.colors = ChartColorTemplates.material()
                
                // let chartData = BarChartData(xVals: self.weekdays, dataSets: chartDataSet)
                let chartData = BarChartData(dataSet: chartDataSet)
                
                self.viewChart.data = chartData
            }
        }
    }
}

//
//  BarChart.swift
//  Expensify2021
//
//  Created by Syed on 30/11/2021.
//

import SwiftUI
import Charts

struct BarChart: UIViewRepresentable {
    typealias UIViewType = BarChartView
    
    let axis: Axis
    let entries: [(label: String, value: Double)]
    var numberStyle: NumberFormatter.Style?
    
    func makeUIView(context: Context) -> UIViewType {
        let barChart: BarChartView
        switch axis {
        case .horizontal:
            barChart = HorizontalBarChartView()
            barChart.legend.orientation = .vertical
        case .vertical:
            barChart = BarChartView()
            barChart.legend.orientation = .horizontal
        }
        barChart.noDataTextAlignment = .center
        barChart.legend.horizontalAlignment = .center
        barChart.xAxis.drawLabelsEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        return barChart
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if !entries.isEmpty {
            let colors = ChartColorTemplates.colorful()
            let data = BarChartData(dataSets: entries.enumerated().map { offset, item in
                let set = BarChartDataSet(entries: [BarChartDataEntry(x: Double(offset), y: item.value)], label: item.label)
                set.setColor(colors[offset%colors.count])
                return set
            })
            data.setValueFont(.systemFont(ofSize: 11, weight: .bold))
            data.setValueTextColor(.black)
            uiView.data = data
            
            let formatter = DefaultValueFormatter(decimals: 0)
            if let numberStyle = numberStyle {
                formatter.formatter?.numberStyle = numberStyle
            }
            data.setValueFormatter(formatter) // must be updated after setting data to chart
        } else {
            uiView.data = nil
        }
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BarChart(
                axis: .vertical,
                entries: [
                    ("Mon", 333),
                    ("Tue", 222),
                    ("Wed", 111)
                ])
            BarChart(
                axis: .horizontal,
                entries: [
                    ("label 1", 33),
                    ("label 2", 22),
                    ("label 3", 11)
                ])
        }
    }
}

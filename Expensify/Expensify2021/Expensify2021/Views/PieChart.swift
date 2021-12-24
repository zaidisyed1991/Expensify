//
//  PieChart.swift
//  Expensify2021
//
//  Created by Syed on 30/11/2021.
//

import SwiftUI
import Charts

struct PieChart: UIViewRepresentable {
    typealias UIViewType = PieChartView
    
    let entries: [PieChartDataEntry]
    var colors = ChartColorTemplates.colorful()
    
    func makeUIView(context: Context) -> PieChartView {
        let pieChart = PieChartView()
        pieChart.noDataTextAlignment = .center
        pieChart.legend.horizontalAlignment = .center
        return pieChart
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        if !entries.isEmpty {
            let set = PieChartDataSet(entries: entries, label: "")
            set.sliceSpace = 2
            set.colors = colors
            
            let data = PieChartData(dataSet: set)
            data.setValueFont(.systemFont(ofSize: 11, weight: .bold))
            data.setValueTextColor(.black)
            
            uiView.data = data
            
            let formatter = DefaultValueFormatter(decimals: 0)
            data.setValueFormatter(formatter) // must be updated after setting data to chart
        } else {
            uiView.data = nil
        }
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        PieChart(entries: [
            .init(value: 11, label: "Approved"),
            .init(value: 22, label: "Rejected"),
            .init(value: 33, label: "Under review")
        ])
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var uiColor: UIColor {
        UIColor(self)
    }
}

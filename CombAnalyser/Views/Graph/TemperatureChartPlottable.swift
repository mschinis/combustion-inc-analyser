//
//  TemperatureChartPlottable.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 21/11/2023.
//

import Charts
import Foundation
import SwiftUI

/// Defines all chart data and their associated colors, which are used as the legend at the bottom of the chart
enum TemperatureChartPlottable: String, Plottable {
    case core = "Core Temperature"
    case surface = "Surface Temperature"
    case ambient = "Ambient Temperature"
    
    case t1 = "T1 (Tip)"
    case t2 = "T2"
    case t3 = "T3"
    case t4 = "T4"
    case t5 = "T5"
    case t6 = "T6"
    case t7 = "T7"
    case t8 = "T8 (Handle)"
    
    case probeNotInserted = "Probe removed"
    
    /// The color of the temperature curve
    var color: Color {
        switch self {
        case .core: return .blue
        case .surface: return .yellow
        case .ambient: return .red
        case .t1: return .orange
        case .t2: return .purple
        case .t3: return .cyan
        case .t4: return .teal
        case .t5: return .mint
        case .t6: return .pink
        case .t7: return .brown
        case .t8: return .black
        case .probeNotInserted: return .gray
        }
    }
}

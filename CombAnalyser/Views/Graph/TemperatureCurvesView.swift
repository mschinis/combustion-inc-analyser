//
//  TemperatureCurvesView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 16/11/2023.
//

import Charts
import SwiftUI

struct TemperatureCurvesView: ChartContent {
    /// The temperature unit being used right now
    var temperatureUnit: TemperatureUnit
    /// The temperature graph curves which are enabled
    var enabledCurves: AppSettingsEnabledCurves
    /// The parsed csv row which should be rendered
    var row: CookTimelineRow
    
    /// Returns a LineMark object for the specified temperature curve.
    ///
    /// - Parameters:
    ///   - series: The series of the given value
    ///   - value: The "y" value on the graph, for the given series
    /// - Returns: LineMark view to be used onthe chart
    func lineMark(series: TemperatureChartPlottable, value: TemperatureReading) -> some ChartContent {
        LineMark(
            x: .value("Time", row.timestamp),
            y: .value(series.rawValue, value.value(for: temperatureUnit)),
            series: .value(series.rawValue, series)
        )
        .foregroundStyle(by: .value("Series", series))
    }
    
    var body: some ChartContent {
        if enabledCurves.core {
            lineMark(series: .core, value: row.virtualCoreTemperature)
        }

        if enabledCurves.surface {
            lineMark(series: .surface, value: row.virtualSurfaceTemperature)
        }
        
        if enabledCurves.ambient {
            lineMark(series: .ambient, value: row.virtualAmbientTemperature)
        }
        
        if enabledCurves.t1 {
            lineMark(series: .t1, value: row.t1)
        }
        
        if enabledCurves.t2 {
            lineMark(series: .t2, value: row.t2)
        }
        
        if enabledCurves.t3 {
            lineMark(series: .t3, value: row.t3)
        }

        if enabledCurves.t4 {
            lineMark(series: .t4, value: row.t4)
        }
        
        if enabledCurves.t5 {
            lineMark(series: .t5, value: row.t5)
        }
        
        if enabledCurves.t6 {
            lineMark(series: .t6, value: row.t6)
        }
        
        if enabledCurves.t7 {
            lineMark(series: .t7, value: row.t7)
        }
        
        if enabledCurves.t8 {
            lineMark(series: .t8, value: row.t8)
        }
    }
}


#Preview {
    Chart {
        let temp = TemperatureReading(celsius: 1)

        TemperatureCurvesView(
            temperatureUnit:  .celsius,
            enabledCurves: AppSettingsEnabledCurves.defaults,
            row: CookTimelineRow(
                timestamp: 0,
                sessionID: "0",
                sequenceNumber: 1,
                t1: temp,
                t2: temp,
                t3: temp,
                t4: temp,
                t5: temp,
                t6: temp,
                t7: temp,
                t8: temp,
                virtualCoreTemperature: temp,
                virtualSurfaceTemperature: temp,
                virtualAmbientTemperature: temp,
                estimatedCoreTemperature: temp,
                predictionSetPoint: 2,
                virtualCoreSensor: .t1,
                virtualSurfaceSensor: .t4,
                virtualAmbientSensor: .t8,
                predictionState: .probeNotInserted,
                predictionMode: .timeToRemoval,
                predictionType: .none,
                predictionValueSeconds: 10
            )
        )
    }
}

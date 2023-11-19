//
//  TemperatureCurvesView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 16/11/2023.
//

import Charts
import SwiftUI

struct TemperatureCurvesView: ChartContent {
    var temperatureUnit: TemperatureUnit
    var enabledCurves: AppSettingsEnabledCurves
    var row: CookTimelineRow

    var body: some ChartContent {
        if enabledCurves.core {
            // Core temperature graph
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("Core Temperature", row.virtualCoreTemperature.value(for: temperatureUnit)),
                series: .value("Core Temperature", "A")
            )
            .foregroundStyle(.blue)
        }

        if enabledCurves.surface {
            // Surface temperature graph
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("Suface Temperature", row.virtualSurfaceTemperature.value(for: temperatureUnit)),
                series: .value("Surface Temperature", "B")
            )
            .foregroundStyle(.yellow)
        }
        
        if enabledCurves.ambient {
            // Ambient temperature graph
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("Ambient Temperature", row.virtualAmbientTemperature.value(for: temperatureUnit)),
                series: .value("Ambient Temperature", "C")
            )
            .foregroundStyle(.red)
        }
        
        if enabledCurves.t1 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T1", row.t1.value(for: temperatureUnit)),
                series: .value("T1", "T1")
            )
            .foregroundStyle(.orange)
        }
        
        if enabledCurves.t2 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T2", row.t2.value(for: temperatureUnit)),
                series: .value("T2", "T2")
            )
            .foregroundStyle(.purple)
        }
        
        if enabledCurves.t3 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T3", row.t3.value(for: temperatureUnit)),
                series: .value("T3", "T3")
            )
            .foregroundStyle(.cyan)
        }
        
        if enabledCurves.t4 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T4", row.t4.value(for: temperatureUnit)),
                series: .value("T4", "T4")
            )
            .foregroundStyle(.teal)
        }
        
        if enabledCurves.t5 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T5", row.t5.value(for: temperatureUnit)),
                series: .value("T5", "T5")
            )
            .foregroundStyle(.mint)
        }
        
        if enabledCurves.t6 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T6", row.t6.value(for: temperatureUnit)),
                series: .value("T6", "T6")
            )
            .foregroundStyle(.pink)
        }
        
        if enabledCurves.t7 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T7", row.t7.value(for: temperatureUnit)),
                series: .value("T7", "T7")
            )
            .foregroundStyle(.brown)
        }
        
        if enabledCurves.t8 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T8", row.t8.value(for: temperatureUnit)),
                series: .value("T8", "T8")
            )
            .foregroundStyle(.black)
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

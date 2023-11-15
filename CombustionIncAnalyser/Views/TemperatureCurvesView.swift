//
//  TemperatureCurvesView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 16/11/2023.
//

import Charts
import SwiftUI

struct TemperatureCurvesView: ChartContent {
    var enabledCurves: AppSettingsEnabledCurves
    var row: CookTimelineRow

//    @AppStorage(AppSettingsKeys.enabledCurves.rawValue) private var enabledCurves: AppSettingsEnabledCurves = .defaults
    
//    @AppStorage(AppSettings.graphsCore.rawValue) private var isGraphCoreEnabled: Bool = true
//    @AppStorage(AppSettings.graphsSurface.rawValue) private var isGraphSurfaceEnabled: Bool = true
//    @AppStorage(AppSettings.graphsAmbient.rawValue) private var isGraphAmbientEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsNotes.rawValue) private var isGraphNotesEnabled: Bool = true

    var body: some ChartContent {
        if enabledCurves.core {
            // Core temperature graph
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("Core Temperature", row.virtualCoreTemperature),
                series: .value("Core Temperature", "A")
            )
            .foregroundStyle(.blue)
        }

        if enabledCurves.surface {
            // Surface temperature graph
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("Suface Temperature", row.virtualSurfaceTemperature),
                series: .value("Surface Temperature", "B")
            )
            .foregroundStyle(.yellow)
        }
        
        if enabledCurves.ambient {
            // Ambient temperature graph
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("Ambient Temperature", row.virtualAmbientTemperature),
                series: .value("Ambient Temperature", "C")
            )
            .foregroundStyle(.red)
        }
        
        if enabledCurves.t1 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T1", row.t1),
                series: .value("T1", "T1")
            )
            .foregroundStyle(.orange)
        }
        
        if enabledCurves.t2 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T2", row.t2),
                series: .value("T2", "T2")
            )
            .foregroundStyle(.purple)
        }
        
        if enabledCurves.t3 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T3", row.t3),
                series: .value("T3", "T3")
            )
            .foregroundStyle(.cyan)
        }
        
        if enabledCurves.t4 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T4", row.t4),
                series: .value("T4", "T4")
            )
            .foregroundStyle(.teal)
        }
        
        if enabledCurves.t5 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T5", row.t5),
                series: .value("T5", "T5")
            )
            .foregroundStyle(.mint)
        }
        
        if enabledCurves.t6 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T6", row.t6),
                series: .value("T6", "T6")
            )
            .foregroundStyle(.pink)
        }
        
        if enabledCurves.t7 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T7", row.t7),
                series: .value("T7", "T7")
            )
            .foregroundStyle(.brown)
        }
        
        if enabledCurves.t8 {
            LineMark(
                x: .value("Timestamp", row.timestamp),
                y: .value("T8", row.t8),
                series: .value("T8", "T8")
            )
            .foregroundStyle(.black)
        }

        if isGraphNotesEnabled, let _ = row.notes {
            PointMark(
                x: .value("X", row.timestamp),
                y: .value("Y", 0)
            )
            .symbol {
                Image(systemName: "note")
                    .offset(y: -16)
                    .foregroundStyle(.blue)
            }
        }
    }
}


#Preview {
    Chart {
        TemperatureCurvesView(
            enabledCurves: AppSettingsEnabledCurves.defaults,
            row: CookTimelineRow(timestamp: 0, sessionID: "0", sequenceNumber: 1, t1: 2, t2: 2, t3: 2, t4: 2, t5: 2, t6: 2, t7: 2, t8: 2, virtualCoreTemperature: 2, virtualSurfaceTemperature: 2, virtualAmbientTemperature: 2, estimatedCoreTemperature: 2, predictionSetPoint: 2, virtualCoreSensor: .t1, virtualSurfaceSensor: .t4, virtualAmbientSensor: .t8, predictionState: .probeNotInserted, predictionMode: .timeToRemoval, predictionType: .none, predictionValueSeconds: 10)
        )
    }
}

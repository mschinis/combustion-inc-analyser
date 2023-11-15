//
//  GraphView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/11/2023.
//

import Charts
import SwiftUI

struct GraphHoverPosition {
    var x: Float
    
    var sequenceNumber: Int
    
    var core: Float
    var surface: Float
    var ambient: Float
}

struct NotInsertedRange: Identifiable {
    var id: String {
        "\(lower)_\(upper)"
    }

    var lower: Double
    var upper: Double
}


struct GraphView: View {
    var enabledCurves: AppSettingsEnabledCurves
    var data: [CookTimelineRow]
    @Binding var noteHoveredTimestamp: Double?
    @Binding var graphAnnotationRequest: GraphAnnotationRequest?

    @State private var graphHoverPosition: GraphHoverPosition? = nil

    
//    @AppStorage(AppSettingsKeys.enabledCurves.rawValue) private var enabledCurves: AppSettingsEnabledCurves = .defaults

//    @AppStorage(AppSettings.graphsCore.rawValue) private var isGraphCoreEnabled: Bool = true
//    @AppStorage(AppSettings.graphsSurface.rawValue) private var isGraphSurfaceEnabled: Bool = true
//    @AppStorage(AppSettings.graphsAmbient.rawValue) private var isGraphAmbientEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsNotes.rawValue) private var isGraphNotesEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsProbeNotInserted.rawValue) private var isGraphsProbeNotInsertedEnabled: Bool = true
    @AppStorage(AppSettingsKeys.performanceMode.rawValue) private var isPerformanceModeEnabled: Bool = true

    /// For performance, sample the graph and only show every second data point
    private var _data: [CookTimelineRow] {
        guard isPerformanceModeEnabled else {
            return data
        }
        
        // Reduce graph resolution by 50%, when performance mode is enabled
        return data.filter { $0.sequenceNumber % 3 == 0 }
    }

    typealias NotInsertedTemp = (lower: Double, upper: Double, isCompleted: Bool)
    private var _notInsertedRanges: [NotInsertedRange] {
        guard isGraphsProbeNotInsertedEnabled else {
            return []
        }
        
        return data
            .reduce(into: [NotInsertedTemp]()) { partialResult, row in
                // If the probe is not inserted, mark the previous iteration as completed, and move on
                guard row.predictionState == .probeNotInserted else {
                    if let latestResult = partialResult.last, latestResult.isCompleted == false {
                        partialResult[partialResult.count - 1] = (latestResult.lower, latestResult.upper, true)
                    }
                    return
                }

                // *** Probe not inserted ***
                if let latestResult = partialResult.last {
                    if latestResult.isCompleted {
                        // If the previous group is already completed, create a new group
                        partialResult.append(
                            (
                                lower: row.timestamp,
                                upper: row.timestamp,
                                isCompleted: false
                            )
                        )
                    } else {
                        // If the previous group is not completed, update it
                        partialResult[partialResult.count - 1] = (
                            lower: latestResult.lower,
                            upper: row.timestamp,
                            isCompleted: false
                        )
                    }
                } else {
                    // If no groups exist, create a new group
                    partialResult = [
                        (lower: row.timestamp, upper: row.timestamp, isCompleted: false)
                    ]
                }
            }
            .map { temp in
                NotInsertedRange(lower: temp.lower, upper: temp.upper)
            }
    }

    /// Returns a struct with all the resolved positions on the graph, for the core, surface, ambient and "x" position
    /// so we can annotate the graph.
    ///
    /// - Parameter x: The horizontal position where the user is hovering over the graph
    /// - Returns: The information of where we should highlight the graph
    func value(x: Float) -> GraphHoverPosition? {
        // Round to the closest 5th second, since the data is structured as such
        let closestValue = Double(round(x / 5) * 5)
        
        // Find the temperature data which corresponds to the hovered position on the graph
        let row = data.first { row in
            row.timestamp == closestValue
        }

        guard let row else {
            return nil
        }

        return GraphHoverPosition(
            x: x,
            
            sequenceNumber: row.sequenceNumber,

            core: row.estimatedCoreTemperature,
            surface: row.virtualSurfaceTemperature,
            ambient: row.virtualAmbientTemperature
        )
    }
    
    var chartColors: KeyValuePairs<String, Color> {
//        var colors: [Color] = []
//        
//        if enabledCurves.ambient {
//            colors.append(Color.blue)
//        }
//        
//        if enabledCurves.surface {
//            colors.append(Color.yellow)
//        }
//        
//        if enabledCurves.ambient {
//            colors.append(Color.red)
//        }
//        
//        if enabledCurves.t1 {
//            colors.append(Color.orange)
//        }
//        
//        if enabledCurves.t2 {
//            colors.append(Color.purple)
//        }
//        
//        if enabledCurves.t3 {
//            colors.append(Color.cyan)
//        }
//        
//        if enabledCurves.t4 {
//            colors.append(Color.teal)
//        }
//        
//        if enabledCurves.t5 {
//            colors.append(Color.mint)
//        }
//        
//        if enabledCurves.t6 {
//            colors.append(Color.pink)
//        }
//        
//        if enabledCurves.t7 {
//            colors.append(Color.brown)
//        }
//        
//        if enabledCurves.t8 {
//            colors.append(Color.black)
//        }

        
        
        return [
            "Core Temperature": Color.blue,
            "Suface Temperature": Color.yellow,
            "Ambient Temperature": Color.red,
            "Probe not inserted": Color.gray.opacity(0.2),
            "T1 (tip)": Color.orange,
            "T2": Color.purple,
            "T3": Color.cyan,
            "T4": Color.teal,
            "T5": Color.mint,
            "T6": Color.pink,
            "T7": Color.brown,
            "T8": Color.black
        ]
    }

    var body: some View {
        Chart {
            ForEach(_data) {
                TemperatureCurvesView(enabledCurves: enabledCurves, row: $0)
            }

            ForEach(_notInsertedRanges) {
                    RectangleMark(
                        xStart: .value("X1", $0.lower),
                        xEnd: .value("X2", $0.upper)
                    )
                    .foregroundStyle(.gray)
                    .opacity(0.1)
            }
            
            if let noteHoveredTimestamp {
                RuleMark(x: .value("X", noteHoveredTimestamp))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                    .foregroundStyle(.gray.opacity(0.8))
            }

            // Show the points on the graph being hovered over.
            if let graphHoverPosition {
                // Vertical line on hover
                RuleMark(x: .value("X", graphHoverPosition.x))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                    .foregroundStyle(.yellow.opacity(0.8))
            }
        }
//        .chartForegroundStyleScale(range: graphColors())
        .chartForegroundStyleScale(chartColors)
        // Get mouse position over the graph
        .chartOverlay { proxy in
            Color.clear
                .onContinuousHover { hoverPhase in
                    switch hoverPhase {
                    case .active(let cGPoint):
                        let xPosition = proxy.value(atX: cGPoint.x, as: Float.self)!
                        self.graphHoverPosition = value(x: xPosition)
                    case .ended:
                        self.graphHoverPosition = nil
                    }
                }
                .onTapGesture {
                    if let graphHoverPosition {
                        self.graphAnnotationRequest = GraphAnnotationRequest(
                            sequenceNumber: graphHoverPosition.sequenceNumber
                        )
                    }
                }
        }
        .chartYAxis(content: {
            AxisMarks { value in
                if let temp = value.as(Int.self) {
                    AxisGridLine()

                    AxisValueLabel {
                        Text("\(temp)°")
                    }
                }
                
            }
        })
        .chartXAxis(content: {
            AxisMarks(
                values: .stride(by: 900)
            ) { value in
                if let interval = value.as(TimeInterval.self) {
                    AxisGridLine()
                    
                    AxisValueLabel {
                        Text(
                            interval.hourMinuteFormat()
                        )
                    }
                }
            }
        })
        .padding()
    }
}

#Preview {
    GraphView(
        enabledCurves: AppSettingsEnabledCurves.defaults,
        data: [],
        noteHoveredTimestamp: .constant(nil),
        graphAnnotationRequest: .constant(nil)
    )
}

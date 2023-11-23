//
//  GraphView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/11/2023.
//

import Charts
import SwiftUI

struct GraphView: View {
    /// List of enabled curves to be displayed on the graph
    var enabledCurves: AppSettingsEnabledCurves
    /// The preferred unit of temperature from the settings
    var temperatureUnit: TemperatureUnit
    /// The data to render on the chart
    var data: [CookTimelineRow]
    /// List of notes to display
    var notes: [CookTimelineRow]
    
    /// The note that is currently being hovered on
    @Binding var noteHoverPosition: GraphTimelinePosition?
    /// A temporary variable which stores the note creation/editing payload
    @Binding var graphAnnotationRequest: GraphAnnotationRequest?

    /// The current position of the mouse over the graph, with the associated data to display
    @State private var graphHoverPosition: GraphTimelinePosition? = nil

    @AppStorage(AppSettingsKeys.graphsNotes.rawValue) private var isGraphNotesEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsProbeNotInserted.rawValue) private var isGraphsProbeNotInsertedEnabled: Bool = true
    @AppStorage(AppSettingsKeys.performanceMode.rawValue) private var isPerformanceModeEnabled: Bool = true

    /// For performance, sample the graph and only show every second data point
    private var _data: [CookTimelineRow] {
        guard isPerformanceModeEnabled else {
            return data
        }

        // Reduce graph resolution by 50%, when performance mode is enabled
        return data.filter { $0.sequenceNumber % 5 == 0 }
    }

    typealias NotInsertedTemp = (lower: Double, upper: Double, isCompleted: Bool)

    /// Calculates the range at which the probe was not inserted, by looking at the PredictionState property from the csv.
    /// If the setting is disabled via settings, this returns an empty array.
    /// If the setting is enabled, it generates an array of lower/upper bounds that indicates the times where the probe is removed
    private var _notInsertedRanges: [ProbeNotInsertedRange] {
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
                ProbeNotInsertedRange(lower: temp.lower, upper: temp.upper)
            }
    }

    /// Returns a struct with all the resolved positions on the graph, for the core, surface, ambient and "x" position
    /// so we can annotate the graph.
    ///
    /// - Parameter x: The horizontal position where the user is hovering over the graph
    /// - Returns: The information of where we should highlight the graph
    func value(x: Float) -> GraphTimelinePosition? {
        // Round to the closest 5th second, since the data is structured as such
        let closestValue = Double(round(x / 5) * 5)
        
        // Find the temperature data which corresponds to the hovered position on the graph
        let row = data.first { row in
            row.timestamp == closestValue
        }

        guard let row else {
            return nil
        }

        return GraphTimelinePosition(
            x: x,

            data: row
        )
    }
    
    /// Controls whether the location of the annotation view should be at the left or the right of the rule mark line
    ///
    /// - Parameters:
    ///   - currentPosition: The current position of the rule mark/line
    /// - Returns: True when the rulemark is at the last 20% of the time axis, false when it's at the first 80%
    func isRuleMarkAnnotationTrailing(ruleMarkPosition: Int) -> Bool {
        let distance = Double(data.count) - Double(ruleMarkPosition)
        let percentage = distance / Double(data.count)
        
        if Device.current.isDevice(.iPhone) {
            return percentage > 0.5
        } else {
            return percentage > 0.25
        }
    }
    
    /// Creates a label to be used in the graph annotation, for each temperature, and formats the temperature to two decimal places
    /// - Parameters:
    ///   - label: Label to be displayed in bold
    ///   - value: Value to be formatted
    /// - Returns: The formatted string
    func formatAnnotationTemperature(label: String, value: Float) -> AttributedString {
        let formattedValue = String(format: "%.2f", value)
        return try! AttributedString(markdown: "**\(label):** \(formattedValue)°")
    }
    
    /// Returns a view to be used as an annotation, displaying the temperatures on the graph
    /// - Parameters:
    ///   - time: The time variable, which should as the first metric
    ///   - data: The probe temperatures which correspond to the time
    /// - Returns: The view to display in the annotation
    func annotationView(for time: Float, data: CookTimelineRow) -> some View {
        VStack(alignment: .leading) {
            Text("**Time:** \(TimeInterval(time).hourMinuteFormat())")
            
            if enabledCurves.core {
                Text(
                    formatAnnotationTemperature(
                        label: "Core",
                        value: data.virtualCoreTemperature.value(for: temperatureUnit)
                    )
                )
            }

            if enabledCurves.surface {
                Text(
                    formatAnnotationTemperature(
                        label: "Surface",
                        value: data.virtualSurfaceTemperature.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.ambient {
                Text(
                    formatAnnotationTemperature(
                        label: "Ambient",
                        value: data.virtualAmbientTemperature.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t1 {
                Text(
                    formatAnnotationTemperature(
                        label: "T1 (Tip)",
                        value: data.t1.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t2 {
                Text(
                    formatAnnotationTemperature(
                        label: "T2",
                        value: data.t2.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t3 {
                Text(
                    formatAnnotationTemperature(
                        label: "T3",
                        value: data.t3.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t4 {
                Text(
                    formatAnnotationTemperature(
                        label: "T4",
                        value: data.t4.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t5 {
                Text(
                    formatAnnotationTemperature(
                        label: "T5",
                        value: data.t5.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t6 {
                Text(
                    formatAnnotationTemperature(
                        label: "T6",
                        value: data.t6.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t7 {
                Text(
                    formatAnnotationTemperature(
                        label: "T7",
                        value: data.t7.value(for: temperatureUnit)
                    )
                )
            }
            if enabledCurves.t8 {
                Text(
                    formatAnnotationTemperature(
                        label: "T8 (Handle)",
                        value: data.t8.value(for: temperatureUnit)
                    )
                )
            }
        }
        .padding()
        .annotationBackground()
    }
    
    var body: some View {
        Chart {
            ForEach(_data) {
                TemperatureCurvesView(
                    temperatureUnit:  temperatureUnit,
                    enabledCurves: enabledCurves,
                    row: $0
                )
            }

            // Highlight the part of the graph where the probe is not inserted in the meat
            ForEach(_notInsertedRanges) {
                    RectangleMark(
                        xStart: .value("X1", $0.lower),
                        xEnd: .value("X2", $0.upper)
                    )
                    .foregroundStyle(by: .value("Probe not inserted", TemperatureChartPlottable.probeNotInserted))
                    .opacity(0.1)
            }
            
            // Add an icon to the chart, for each created note.
            if isGraphNotesEnabled {
                ForEach(notes) {
                    PointMark(
                        x: .value("X", $0.timestamp),
                        y: .value("Y", 0)
                    )
                    .symbol {
                        Image("pencil.and.list.clipboard")
                            .font(.title2)
                            .foregroundColor(Color(.graphNote))
                            .offset(y: -24)
                    }
                }
            }
            
            // When a note is hovered, this displays a vertical line indicating where the note was placed
            if let noteHoverPosition {
                RuleMark(x: .value("X", noteHoverPosition.x))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                    .foregroundStyle(.gray.opacity(0.8))
                    .annotation(
                        position: isRuleMarkAnnotationTrailing(ruleMarkPosition: noteHoverPosition.data.sequenceNumber) ? .trailing : .leading,
                        alignment: .center,
                        spacing: 16
                    ) {
                        annotationView(for: noteHoverPosition.x, data: noteHoverPosition.data)
                    }
            }

            // Show the points on the graph being hovered over.
            if let graphHoverPosition {
                // Vertical line on hover
                RuleMark(x: .value("X", graphHoverPosition.x))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                    .foregroundStyle(.yellow.opacity(0.8))
                    .annotation(
                        position: isRuleMarkAnnotationTrailing(ruleMarkPosition: graphHoverPosition.data.sequenceNumber) ? .trailing : .leading,
                        alignment: .center,
                        spacing: 16
                    ) {
                        annotationView(for: graphHoverPosition.x, data: graphHoverPosition.data)
                    }
            }
        }
        // Map the curve to the correct color
        .chartForegroundStyleScale(mapping: { (plottable: TemperatureChartPlottable) -> Color in
            plottable.color
        })
        // Get mouse position over the graph
        .chartOverlay { proxy in
            Color.clear
            #if os(macOS)
                // On MacOS we have the ability to hover over the graph,
                // so display the LineMark when the user hovers
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
                            sequenceNumber: graphHoverPosition.data.sequenceNumber
                        )
                    }
                }
            #else
                // On iPadOS / iOS, we display the LineMark when the user touches and drags their finger
                .contentShape(Rectangle())
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded({ gestureInfo in
                            
                            let xPosition = proxy.value(atX: gestureInfo.location.x, as: Float.self)!
                            
                            if let tapPosition = value(x: xPosition) {
                                self.graphAnnotationRequest = GraphAnnotationRequest(
                                    sequenceNumber: tapPosition.data.sequenceNumber
                                )
                            }
                        })
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged({ gestureInfo in
                            let location = gestureInfo.location

                            let xPosition = proxy.value(atX: location.x, as: Float.self)!
                            self.graphHoverPosition = value(x: xPosition)
                        })
                )
            #endif
                
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
        .chartXAxisLabel("Time", alignment: .center)
        .chartYAxisLabel("Temperature (\(temperatureUnit.rawValue.capitalized))")
    }
}

#Preview {
    GraphView(
        enabledCurves: AppSettingsEnabledCurves.defaults,
        temperatureUnit: .celsius,
        data: [],
        notes: [],
        noteHoverPosition: .constant(nil),
        graphAnnotationRequest: .constant(nil)
    )
}

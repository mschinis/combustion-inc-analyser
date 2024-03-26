//
//  GraphTimelinePosition.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 21/11/2023.
//

import Foundation

/// Used to indicate the position of where the graph or note is being hovered on
struct GraphTimelinePosition {
    /// The x/time, where this data should be displayed
    var x: Float
    /// The data to be displayed
    var data: CookTimelineRow
}

//
//  TimeInterval.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/11/2023.
//

import Foundation

extension TimeInterval {
    /// Break down the Time Interval to hours and minutes.
    /// Used for graph and notes
    var breakdown: (hours: Int, minutes: Int) {
        let interval = Int(self)

        let minutes = (interval / 60) % 60
        let hours = (interval / (60*60)) % 60
        
        return (hours: hours, minutes: minutes)
    }
    
    /// Format the time interval to hours and minutes, with an easy to understand label
    /// - Returns: Formatted string
    func hourMinuteFormat() -> String {
        let (hours, minutes) = breakdown

        // Labels which are under one hour, look better when displaying just minutes
        if hours == 0 {
            return String(format: "%02dm", minutes)
        } else {
            return String(format: "%02dh %02dm", hours, minutes)
        }
    }
}

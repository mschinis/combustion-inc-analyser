//
//  GraphAnnotationRequest.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 21/11/2023.
//

import Foundation

struct GraphAnnotationRequest: Identifiable {
    var id: Int {
        sequenceNumber
    }
    
    /// The id of the csv row that is currently being created/edited, to add a new note
    var sequenceNumber: Int
    /// The note being created/edited
    var note: String = ""
}

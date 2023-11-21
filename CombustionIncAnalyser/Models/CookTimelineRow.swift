//
//  CookTimelineRow.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import Foundation

enum DecodingCSVError: Error {
    case invalidProperty(String)
}

struct CookTimelineRow: Codable, Identifiable {
    enum Sensor: String, Codable {
        case t1 = "T1",
             t2 = "T2",
             t3 = "T3",
             t4 = "T4",
             t5 = "T5",
             t6 = "T6",
             t7 = "T7",
             t8 = "T8"
    }

    enum PredictionState: String, Codable {
        case probeNotInserted = "Probe Not Inserted",
             probeInserted = "Probe Inserted",
             cooking = "Cooking",
             predicting = "Predicting",
             removalPredictionDone = "Removal Prediction Done"
    }

    enum PredictionMode: String, Codable {
        case none = "None",
             timeToRemoval = "Time to Removal"
    }

    enum PredictionType: String, Codable {
        case none = "None",
             removal = "Removal"
    }
    
    var id: Int {
        sequenceNumber
    }

    var timestamp: Double
    var sessionID: String
    var sequenceNumber: Int

    var t1: TemperatureReading
    var t2: TemperatureReading
    var t3: TemperatureReading
    var t4: TemperatureReading
    var t5: TemperatureReading
    var t6: TemperatureReading
    var t7: TemperatureReading
    var t8: TemperatureReading

    var virtualCoreTemperature:     TemperatureReading
    var virtualSurfaceTemperature:  TemperatureReading
    var virtualAmbientTemperature:  TemperatureReading
    var estimatedCoreTemperature:   TemperatureReading

    var predictionSetPoint:         Float

    var virtualCoreSensor: Sensor
    var virtualSurfaceSensor: Sensor
    var virtualAmbientSensor: Sensor

    var predictionState: PredictionState
    var predictionMode: PredictionMode
    var predictionType: PredictionType

    var predictionValueSeconds: Int
    
    var notes: String? = nil

    var timeInterval: TimeInterval {
        TimeInterval(timestamp)
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case timestamp = "Timestamp"
        case sessionID = "SessionID"
        case sequenceNumber = "SequenceNumber"

        case t1 = "T1"
        case t2 = "T2"
        case t3 = "T3"
        case t4 = "T4"
        case t5 = "T5"
        case t6 = "T6"
        case t7 = "T7"
        case t8 = "T8"

        case virtualCoreTemperature     = "VirtualCoreTemperature"
        case virtualSurfaceTemperature  = "VirtualSurfaceTemperature"
        case virtualAmbientTemperature  = "VirtualAmbientTemperature"
        case estimatedCoreTemperature   = "EstimatedCoreTemperature"
        case predictionSetPoint         = "PredictionSetPoint"

        case virtualCoreSensor          = "VirtualCoreSensor"
        case virtualSurfaceSensor       = "VirtualSurfaceSensor"
        case virtualAmbientSensor       = "VirtualAmbientSensor"

        case predictionState            = "PredictionState"
        case predictionMode             = "PredictionMode"
        case predictionType             = "PredictionType"
        case predictionValueSeconds     = "PredictionValueSeconds"

        case notes                      = "Notes"
    }
}

extension CookTimelineRow {
    init(from dictionary: [String: Any]) throws {
        // Timestamp
        if let timestampString = dictionary[CodingKeys.timestamp.rawValue] as? String,
           let timestamp = Double(timestampString) {
            self.timestamp = timestamp
        } else {
            throw DecodingCSVError.invalidProperty("timestamp")
        }
        
        // Session ID
        if let sessionID = dictionary[CodingKeys.sessionID.rawValue] as? String {
            self.sessionID = sessionID
        } else {
            throw DecodingCSVError.invalidProperty("sessionID")
        }

        // Sequence Number
        if let sequenceNumberString = dictionary[CodingKeys.sequenceNumber.rawValue] as? String,
           let sequenceNumber = Int(sequenceNumberString) {
            self.sequenceNumber = sequenceNumber
        } else {
            throw DecodingCSVError.invalidProperty("sequenceNumber")
        }
        
        // T1
        if let tString = dictionary[CodingKeys.t1.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t1 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t1")
        }

        // T2
        if let tString = dictionary[CodingKeys.t2.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t2 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t2")
        }
        
        // T3
        if let tString = dictionary[CodingKeys.t3.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t3 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t3")
        }
        
        // T4
        if let tString = dictionary[CodingKeys.t4.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t4 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t4")
        }
        
        // T5
        if let tString = dictionary[CodingKeys.t5.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t5 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t5")
        }
        
        // T6
        if let tString = dictionary[CodingKeys.t6.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t6 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t6")
        }
        
        // T7
        if let tString = dictionary[CodingKeys.t7.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t7 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t7")
        }
        
        // T8
        if let tString = dictionary[CodingKeys.t8.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.t8 = temp
        } else {
            throw DecodingCSVError.invalidProperty("t8")
        }

        // virtualCoreTemperature
        if let tString = dictionary[CodingKeys.virtualCoreTemperature.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.virtualCoreTemperature = temp
        } else {
            throw DecodingCSVError.invalidProperty("virtualCoreTemperature")
        }

        // virtualSurfaceTemperature
        if let tString = dictionary[CodingKeys.virtualSurfaceTemperature.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.virtualSurfaceTemperature = temp
        } else {
            throw DecodingCSVError.invalidProperty("virtualSurfaceTemperature")
        }

        // virtualAmbientTemperature
        if let tString = dictionary[CodingKeys.virtualAmbientTemperature.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.virtualAmbientTemperature = temp
        } else {
            throw DecodingCSVError.invalidProperty("virtualAmbientTemperature")
        }

        // estimatedCoreTemperature
        if let tString = dictionary[CodingKeys.estimatedCoreTemperature.rawValue] as? String,
           let tFloat = Float(tString) {
            let temp = TemperatureReading(celsius: tFloat)
            self.estimatedCoreTemperature = temp
        } else {
            throw DecodingCSVError.invalidProperty("estimatedCoreTemperature")
        }

        // predictionSetPoint
        if let tString = dictionary[CodingKeys.predictionSetPoint.rawValue] as? String,
           let tFloat = Float(tString) {
            self.predictionSetPoint = tFloat
        } else {
            throw DecodingCSVError.invalidProperty("predictionSetPoint")
        }

        // virtualCoreSensor
        if let sensorStr = dictionary[CodingKeys.virtualCoreSensor.rawValue] as? String,
           let sensor = Sensor(rawValue: sensorStr) {
            self.virtualCoreSensor = sensor
        } else {
            throw DecodingCSVError.invalidProperty("virtualCoreSensor")
        }

        // virtualSurfaceSensor
        if let sensorStr = dictionary[CodingKeys.virtualSurfaceSensor.rawValue] as? String,
           let sensor = Sensor(rawValue: sensorStr) {
            self.virtualSurfaceSensor = sensor
        } else {
            throw DecodingCSVError.invalidProperty("virtualSurfaceSensor")
        }

        // virtualAmbientSensor
        if let sensorStr = dictionary[CodingKeys.virtualAmbientSensor.rawValue] as? String,
           let sensor = Sensor(rawValue: sensorStr) {
            self.virtualAmbientSensor = sensor
        } else {
            throw DecodingCSVError.invalidProperty("virtualAmbientSensor")
        }

        // predictionState
        if let stateStr = dictionary[CodingKeys.predictionState.rawValue] as? String,
           let state = PredictionState(rawValue: stateStr) {
            self.predictionState = state
        } else {
            throw DecodingCSVError.invalidProperty("predictionState")
        }

        // predictionMode
        if let modeStr = dictionary[CodingKeys.predictionMode.rawValue] as? String,
           let mode = PredictionMode(rawValue: modeStr) {
            self.predictionMode = mode
        } else {
            throw DecodingCSVError.invalidProperty("predictionMode")
        }

        // predictionType
        if let typeStr = dictionary[CodingKeys.predictionType.rawValue] as? String,
           let type = PredictionType(rawValue: typeStr) {
            self.predictionType = type
        } else {
            throw DecodingCSVError.invalidProperty("predictionType")
        }

        // predictionValueSeconds
        if let predictionValueStr = dictionary[CodingKeys.predictionValueSeconds.rawValue] as? String,
           let value = Int(predictionValueStr) {
            self.predictionValueSeconds = value
        } else {
            throw DecodingCSVError.invalidProperty("predictionValueSeconds")
        }

        // Notes
        self.notes = dictionary[CodingKeys.notes.rawValue] as? String
    }
    
    /// Converts this object into a dictionary, in order to convert it back to CSV, when saving.
    var serializedDictionary: [String: String] {
        var encoder = JSONEncoder()
        let dictionary = (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
        
        // Convert everything back to string, in order to save back to CSV
        return dictionary.reduce(into: [String:String](), { partialResult, current in
            if let newValue = current.value as? Int {
                partialResult[current.key] = String(newValue)
                return
            }

            if let newValue = current.value as? Double {
                partialResult[current.key] = String(newValue)
                return
            }

            if let newValue = current.value as? Float {
                partialResult[current.key] = String(newValue)
                return
            }
            
            if let newValue = current.value as? String {
                partialResult[current.key] = newValue
                return
            }
        })
    }
}


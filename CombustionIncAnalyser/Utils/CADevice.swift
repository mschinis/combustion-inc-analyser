//
//  CADevice.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 23/11/2023.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

class CADevice {
    enum DeviceType {
        case iPhone, iPad, mac
    }
    
    static var current = CADevice()
    
    func isDevice(_ device: DeviceType) -> Bool {
        #if os(macOS)
        return device == .mac
        #else
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        
        switch device {
        case .iPhone:
            return userInterfaceIdiom == .phone
        case .iPad:
            return userInterfaceIdiom == .pad
        case .mac:
            return false
        }
        #endif
    }
}

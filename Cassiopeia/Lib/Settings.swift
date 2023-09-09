//
//  Settings.swift
//  Cassiopeia
//
//  Created by aydar.media on 09.09.2023.
//

import Foundation

public struct Settings {
    public enum Key: String, CaseIterable {
        case deviceId = "DEVICE_ID"
    }
    
    public static let defaults = UserDefaults.standard
}


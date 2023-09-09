//
//  Security.swift
//  Cassiopeia
//
//  Created by aydar.media on 13.08.2023.
//

struct KeychainEntity {
    public static let serviceName = "com.aydarmedia.cassiopeia"
    
    public enum Account: String, CaseIterable {
        case appSecret = "APP_SECRET"
        case appId = "APP_ID"
    }
}

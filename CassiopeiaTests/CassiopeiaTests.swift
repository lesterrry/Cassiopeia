//
//  CassiopeiaTests.swift
//  CassiopeiaTests
//
//  Created by aydar.media on 09.09.2023.
//

import XCTest

final class CassiopeiaSettingsTests: XCTestCase {

    func testUserDefaultsFlow() throws {
        let key = "TEST"
        let value = "FURRY"
        
        Settings.defaults.set(value, forKey: key)
        
        var retrievedValue = Settings.defaults.string(forKey: key)
        
        XCTAssertEqual(retrievedValue, value)
        
        Settings.defaults.removeObject(forKey: key)
        
        retrievedValue = Settings.defaults.string(forKey: key)
        
        XCTAssertNil(retrievedValue)
    }

}

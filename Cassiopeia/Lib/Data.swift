//
//  Data.swift
//  Cassiopeia
//
//  Created by aydar.media on 10.09.2023.
//

import Foundation
import Constellation

public struct DescriptiveDevice {
    public enum State {
        case armed
        case disarmed
        case running
        case alarm
        case service
        case stayHome
        case unknown
    }
    
    public let alias: String?
    
    @DescriptiveBoolean(trueDescription: Strings.genericOpenLabel.description, falseDescription: Strings.genericClosedLabel.description)
        public var doorsOpen: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOnLabel.description, falseDescription: Strings.genericOffLabel.description)
        public var parkingBrakeEngaged: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOpenLabel.description, falseDescription: Strings.genericClosedLabel.description)
        public var hoodOpen: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOpenLabel.description, falseDescription: Strings.genericClosedLabel.description)
        public var trunkOpen: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOnLabel.description, falseDescription: Strings.genericOffLabel.description)
        public var ignitionPowered: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOnLabel.description, falseDescription: Strings.genericOffLabel.description)
        public var isArmed: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericYesLabel.description, falseDescription: Strings.genericNoLabel.description) public var alarmTriggered: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOnLabel.description, falseDescription: Strings.genericOffLabel.description)
        public var valetModeOn: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOnLabel.description, falseDescription: Strings.genericOffLabel.description)
        public var stayHomeModeOn: Bool? = nil
    
    @DescriptiveFloat(steps: [(28...40, "окей")], fallback: "ХЗ")
        public var gsmLevel: Float? = nil
    
    public var gpsLevel: Float? = nil
    
    public var remainingDistance: Int? = nil
    public var batteryVoltage: Float? = nil
    public var temperature: Float? = nil
    
    public func state() -> State? {
        if self.alarmTriggered ?? false { return .alarm }
        if self.valetModeOn ?? false { return .service }
        if self.ignitionPowered ?? false { return .running }
        if self.stayHomeModeOn ?? false { return .stayHome }
        if let arm = self.isArmed { return arm ? .armed : .disarmed }
        return .unknown
    }
    public func perimeter() -> String {
        guard let doors = self.doorsOpen, let trunk = self.trunkOpen, let hood = self.hoodOpen else { return Strings.genericUnknownLabel.description }
        if !doors && !trunk && !hood { return Strings.genericClosedLabel.description }
        else { return Strings.brokenPerimeterLabel.description }
    }
}

@propertyWrapper
public struct DescriptiveFloat {
    public typealias Steps = [(ClosedRange<Int>, String)]
    
    private var value: Float?
    private let steps: Steps
    private let fallback: String
    private let description: String
    
    public init(wrappedValue: Float?, steps: Steps, fallback: String) {
        func getDescription() -> String {
            guard let value = wrappedValue else { return fallback }
            for i in steps {
                if i.0.contains(Int(value)) { return i.1 }
            }
            return fallback
        }
        
        self.value = wrappedValue
        self.steps = steps
        self.fallback = fallback
        self.description = getDescription()
    }
    
    public var wrappedValue: Float? {
        get { value }
        set { value = newValue }
    }
    
    public var projectedValue: String {
        return description
    }
    
}

@propertyWrapper
public struct DescriptiveBoolean {
    private var value: Bool?
    private let trueDescription: String
    private let falseDescription: String
    
    public init(wrappedValue: Bool?, trueDescription: String = "да", falseDescription: String = "нет") {
        self.value = wrappedValue
        self.trueDescription = trueDescription
        self.falseDescription = falseDescription
    }
    
    public var wrappedValue: Bool? {
        get { value }
        set { value = newValue }
    }
    
    public var projectedValue: String {
        switch value {
        case .some(true):
            return trueDescription
        case .some(false):
            return falseDescription
        case .none:
            return "неизв"
        }
    }
}

public extension ApiResponse.Device {
    func descriptive() -> DescriptiveDevice {
        return DescriptiveDevice(
            alias: self.alias,
            doorsOpen: self.state?.door,
            gsmLevel: self.common?.gsmLevel
        )
    }
}

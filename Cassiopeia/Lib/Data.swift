//
//  Data.swift
//  Cassiopeia
//
//  Created by aydar.media on 10.09.2023.
//

import Foundation
import Constellation

public protocol AppendixApplicable {}

extension Int: AppendixApplicable {}
extension Float: AppendixApplicable {}
extension String: AppendixApplicable {}


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
    @DescriptiveBoolean(trueDescription: Strings.genericYesLabel.description, falseDescription: Strings.genericNoLabel.description)
        public var alarmTriggered: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOnLabel.description, falseDescription: Strings.genericOffLabel.description)
        public var valetModeOn: Bool? = nil
    @DescriptiveBoolean(trueDescription: Strings.genericOnLabel.description, falseDescription: Strings.genericOffLabel.description)
        public var stayHomeModeOn: Bool? = nil
    
    @DescriptiveFloat(steps: [
        (0...20, Strings.genericPoorLabel.description),
        (20...24, Strings.genericNormalLabel.description),
        (24...28, Strings.genericWellLabel.description),
        (28...100, Strings.genericExcellentLabel.description)
    ], fallback: Strings.genericUnknownLabel.description)
        public var gsmLevel: Float? = nil
    
    @DescriptiveFloat(steps: [
        (0...4, Strings.genericPoorLabel.description),
        (4...8, Strings.genericNormalLabel.description),
        (8...10, Strings.genericWellLabel.description),
        (10...100, Strings.genericExcellentLabel.description)
    ], fallback: Strings.genericUnknownLabel.description)
        public var gpsLevel: Float? = nil
    
    @WithAppendix(appendix: Strings.kilometerLabel.description)
        public var remainingDistance: Int? = nil
    @WithAppendix(appendix: Strings.voltLabel.description)
        public var batteryVoltage: Float? = nil
    @WithAppendix(appendix: Strings.celsiusLabel.description)
        public var temperature: Float? = nil
    
    public func state() -> State {
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
    
    public init(wrappedValue: Bool?, trueDescription: String = Strings.genericYesLabel.description, falseDescription: String = Strings.genericNoLabel.description) {
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
            return Strings.genericUnknownLabel.description
        }
    }
}

@propertyWrapper
public struct WithAppendix<T: AppendixApplicable> {
    private var value: T?
    private let appendix: String
    
    public init(wrappedValue: T?, appendix: String) {
        self.value = wrappedValue
        self.appendix = appendix
    }
    
    public var wrappedValue: T? {
        get { value }
        set { value = newValue }
    }
    
    public var projectedValue: String {
        if self.value == nil { return "--\(appendix)" }
        
        return String(describing: self.value!) + appendix
    }
}

public extension ApiResponse.Device {
    func descriptive() -> DescriptiveDevice {
        return DescriptiveDevice(
            alias: self.alias,
            doorsOpen: self.state?.door,
            parkingBrakeEngaged: self.state?.parkingBrake,
            hoodOpen: self.state?.hood,
            trunkOpen: self.state?.trunk,
            ignitionPowered: self.state?.ignition,
            isArmed: self.state?.arm,
            alarmTriggered: self.state?.alarm,
            valetModeOn: self.state?.valet,
            stayHomeModeOn: self.state?.stayHome,
            gsmLevel: self.common?.gsmLevel,
            gpsLevel: self.common?.gpsLevel,
            remainingDistance: self.obd?.remainingDistance,
            batteryVoltage: self.common?.battery,
            temperature: self.common?.moduleTemperature
        )
    }
}

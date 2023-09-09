//
//  Data.swift
//  Cassiopeia
//
//  Created by aydar.media on 10.09.2023.
//

import Foundation

public struct CarData {
    public enum State {
        case armed
        case disarmed
        case running
        case alarm
        case service
        case stayHome
        case unknown
    }
    
    public var alias: String? = nil
    @DescriptiveBooleanState(trueDescription: "откр", falseDescription: "закр") public var doorsOpen: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "вкл", falseDescription: "выкл")  public var parkingBrakeEngaged: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "откр", falseDescription: "закр") public var hoodOpen: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "откр", falseDescription: "закр") public var trunkOpen: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "вкл", falseDescription: "выкл") public var ignitionPowered: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "вкл", falseDescription: "откл") public var isArmed: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "нет", falseDescription: "да") public var alarmTriggered: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "вкл", falseDescription: "выкл") public var valetModeOn: Bool? = nil
    @DescriptiveBooleanState(trueDescription: "вкл", falseDescription: "выкл") public var stayHomeModeOn: Bool? = nil
    public var remainingDistance: Int? = nil
    public var batteryVoltage: Float? = nil
    public var gsmLevel: Float? = nil
    public var gpsLevel: Float? = nil
    public var temp: Float? = nil
    
    public func state() -> State? {
        if self.alarmTriggered ?? false { return .alarm }
        if self.valetModeOn ?? false { return .service }
        if self.ignitionPowered ?? false { return .running }
        if self.stayHomeModeOn ?? false { return .stayHome }
        if let arm = self.isArmed { return arm ? .armed : .disarmed }
        return .unknown
    }
    public func perimeter() -> String {
        guard let doors = self.doorsOpen, let trunk = self.trunkOpen, let hood = self.hoodOpen else { return "неизв" }
        if !doors && !trunk && !hood { return "закр" }
        else { return "наруш" }
    }
    // TODO: move to propertyWrapper for ints
    public func gsmLevelDescription() -> String {
        guard let level = gsmLevel else { return "неизв" }
        switch level {
            case 0...10: return "плох"
            case 10...20: return "норм"
            case 20...30: return "хор"
            default: return "отл"
        }
    }
}

@propertyWrapper
public struct DescriptiveBooleanState {
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

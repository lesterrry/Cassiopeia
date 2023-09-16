//
//  Operations.swift
//  Cassiopeia
//
//  Created by aydar.media on 13.08.2023.
//

import KeychainBridge
import Constellation
import Foundation

fileprivate let keychain = Keychain(serviceName: KeychainEntity.serviceName)

public enum Command: String, CaseIterable {
    case myCars = "allcars"
    case settings = "set"
    case help = "help"
    case exit = "exit"
    
    case getCar = "status"
    case arm = "!arm"
    case disarm = "!disarm"
    case engineStart = "!start"
    case engineStop = "!stop"
    case honk = "!honk"
}

struct OperationResult {
    enum Status {
        case success
        case failure
        case warning
        case silence
    }
    
    public let status: Status
    public let message: String?
    public let output: Any?
    
    public init(_ status: Status, message: String? = nil, output: Any? = nil) {
        self.status = status
        self.message = message
        self.output = output
    }
}

struct Operation {
    public static func settingsPut(key: String, value: String) -> OperationResult {
        Settings.defaults.set(value, forKey: key)
        return OperationResult(.success)
    }
    
    public static func keychainPut(account: String, value: String) -> OperationResult {
        do {
            try keychain.saveToken(value, account: account)
        } catch {
            return OperationResult(.failure, message: String(describing: error))
        }
        return OperationResult(.success)
    }
    
    public static func keychainCheck(account: String) -> OperationResult {
        let keychain = Keychain(serviceName: KeychainEntity.serviceName)
        guard let token = try? keychain.getToken(account: account)
        else { return OperationResult(.warning, message: Strings.keychainEntityNotFoundFailureMessage.description) }
        return OperationResult(.success, output: token)
    }
    
    public static func settingCheck(key: String) -> OperationResult {
        guard let setting = Settings.defaults.string(forKey: key)
        else { return OperationResult(.warning, message: Strings.settingNotFoundFailureMessage.description) }
        return OperationResult(.success, output: setting)
    }
    
    public static func apiInit(appId: String, appSecret: String) -> OperationResult {
        let client = ApiClient(appId: appId, appSecret: appSecret)
        if client.hasUserToken {
            return OperationResult(.success, output: client)
        } else {
            return OperationResult(.warning, message: Strings.authTokenNotFoundWarningMessage.description, output: client)
        }
    }
    
    public static func apiAuth(client: inout ApiClient, login: String, password: String, smsCode: String? = nil) async -> OperationResult {
        var operationResult: OperationResult? = nil
        client.setCredentials(login: login, password: password)
        await client.auth(smsCode: smsCode) { result in
            switch result {
            case .failure(let error):
                guard case ApiClient.AuthError.secondFactorRequired = error else {
                    operationResult = OperationResult(.failure, message: "\(String(describing: error)): \(error as! ApiClient.AuthError)")
                    break
                }
                operationResult = OperationResult(.warning, message: Strings.secondFactorEnabledWarningMessage.description)
            case .success(let token):
                operationResult = OperationResult(.success, output: token)
            }
        }
        return operationResult!
    }
    
    public static func runCommand(_ command: Command, client: ApiClient) async -> OperationResult {
        switch command {
        case .myCars:
            var out: OperationResult? = nil
            await client.getDevicesForCurrentUser { result in
                switch result {
                case .success(let data):
                    let action = {
                        setRawIndentLevel(1)
                        stateUserCars(cars: data)
                        resetRawIndentLevel()
                    }
                    out = OperationResult(.success, output: action)
                case .failure(let error):
                    out = OperationResult(.failure, message: String(describing: error))
                }
            }
            return out!
        case .settings:
            let action = {
                setRawIndentLevel(1)
                state(.line(Strings.availableKeysPredecessor.description + Settings.Key.allCases.map({ $0.rawValue }).joined(separator: ", ")))
                state(.linebreak)
                let keyString = state(.input(Strings.settingKeyPrompt.description)) as! String
                let valueString = state(.input(Strings.settingValuePrompt.description)) as! String
                state(.operation(Strings.genericWritingMessage.description, 1))
                guard let key = Settings.Key(rawValue: keyString) else {
                    state(.operationResult(OperationResult(.failure, message: Strings.settingNotFoundFailureMessage.description), 2))
                    return
                }
                let result = Operation.settingsPut(key: key.rawValue, value: valueString)
                state(.operationResult(result))
                resetRawIndentLevel()
            }
            return OperationResult(.silence, output: action)
        case .help:
            let action = {
                setRawIndentLevel(1)
                state(.line("Cassiopeia \(APP_VERSION)"))
                state(.linebreak)
                state(.line(Strings.availableCommandsPredecessor.description))
                for i in Command.allCases {
                    state(.line(i.rawValue, nil, 1))
                }
                resetRawIndentLevel()
            }
            return OperationResult(.silence, output: action)
        case .exit:
            print()
            exit(0)
        case .getCar:
            guard let idString = Settings.defaults.string(forKey: Settings.Key.deviceId.rawValue), let id = Int(idString) else {
                return OperationResult(.failure, message: Strings.settingNotFoundFailureMessage.description)
            }
            
            var out: OperationResult? = nil
            await client.getDeviceData(for: id) { result in
                switch result {
                case .success(let data):
                    if case ApiResponse.Data.device(let device) = data {
                        let action = {
                            setRawIndentLevel(1)
                            stateCar(device)
                            resetRawIndentLevel()
                        }
                        out = OperationResult(.success, output: action)
                    } else {
                        out = OperationResult(.failure, message: Strings.genericCorruptedDataFatalErrorMessage.description)
                    }
                case .failure(let error):
                    out = OperationResult(.failure, message: String(describing: error))
                }
            }
            return out!

        case .arm:
            return await runSetParamCommand(.arm, client: client)
        case .disarm:
            return await runSetParamCommand(.disarm, client: client)
        case .engineStart:
            return await runSetParamCommand(.ignitionStart, client: client)
        case .engineStop:
            return await runSetParamCommand(.ignitionStop, client: client)
        case .honk:
            return await runSetParamCommand(.honk, client: client)
        }
    }
    
    private static func runSetParamCommand(_ command: ApiClient.Command, client: ApiClient) async -> OperationResult {
        guard let idString = Settings.defaults.string(forKey: Settings.Key.deviceId.rawValue), let id = Int(idString) else {
            return OperationResult(.failure, message: Strings.settingNotFoundFailureMessage.description)
        }
        
        var out: OperationResult? = nil
        await client.runCommand(command, on: id) { result in
            switch result {
            case .success():
                out = OperationResult(.success)
            case .failure(let error):
                out = OperationResult(.failure, message: String(describing: error))
            }
        }
        return out!
    }
}

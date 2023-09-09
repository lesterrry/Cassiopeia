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
    case myCars = "mycars"
    case saveCar = "savecar"
    case getCar = "getcar"
    case exit = "exit"
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
            return OperationResult(.failure, message: error.localizedDescription)
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
                    operationResult = OperationResult(.failure, message: "\(error.localizedDescription): \(error as! ApiClient.AuthError)")
                    break
                }
                operationResult = OperationResult(.warning, message: Strings.secondFactorEnabledWarningMessage.description)
            case .success(let token):
                print(token)
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
                    out = OperationResult(.failure, message: error.localizedDescription)
                }
            }
            return out!
        case .saveCar:
            let action = {
                let id = state(.input(Strings.deviceIdPrompt.description)) as! String
                state(.operation(Strings.genericWritingMessage.description, 2))
                let result = Operation.settingsPut(key: Settings.Key.deviceId.rawValue, value: id)
                state(.operationResult(result))
            }
            return OperationResult(.silence, output: action)
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
                        #warning("Unimplemented")
                    }
                case .failure(let error):
                    out = OperationResult(.failure, message: error.localizedDescription)
                }
            }
            return out!
        case .exit:
            exit(0)
        }
    }
}

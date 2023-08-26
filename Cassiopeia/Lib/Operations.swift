//
//  Operations.swift
//  Cassiopeia
//
//  Created by aydar.media on 13.08.2023.
//

import KeychainBridge
import Constellation

fileprivate let keychain = Keychain(serviceName: KeychainEntity.serviceName)

struct OperationResult {
    enum Status {
        case success
        case failure
        case warning
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
        else { return OperationResult(.failure, message: Strings.keychainEntityNotFoundFailureMessage.description) }
        return OperationResult(.success, output: token)
    }
    
    public static func apiInit(appId: String, appSecret: String) -> OperationResult {
        let client = ApiClient(appId: appId, appSecret: appSecret)
        if client.hasUserToken {
            return OperationResult(.success, output: client)
        } else {
            return OperationResult(.warning, message: Strings.authTokenNotFoundWarningMessage.description, output: client)
        }
    }
    
    public static func apiAuth(_ client: inout ApiClient, login: String, password: String, smsCode: String? = nil) async -> OperationResult {
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
}

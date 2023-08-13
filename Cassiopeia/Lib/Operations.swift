//
//  Operations.swift
//  Cassiopeia
//
//  Created by aydar.media on 13.08.2023.
//

import KeychainBridge

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
    public static func keychainCheck(account: String) -> OperationResult {
        let keychain = Keychain(serviceName: KeychainEntity.serviceName)
        guard let token = try? keychain.getToken(account: account)
        else { return OperationResult(.failure, message: Strings.keychainEntityNotFoundFailureMessage.description) }
        return OperationResult(.success, output: token)
    }
}
